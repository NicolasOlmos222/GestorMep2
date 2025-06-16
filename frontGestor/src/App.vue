<template>
  <div class="container">
    <!-- Login Docente -->
    <div class="login" v-if="!docente && !admin && !mostrarAdmin">
      <h2>Ingreso de Docente</h2>
      <input v-model="dni" placeholder="Ingrese su DNI" @keyup.enter="acceder" />
      <button @click="acceder">Acceder</button>
      <p v-if="error" class="error">{{ error }}</p>
      <hr />
      <button @click="mostrarAdmin = true" class="admin-btn">Acceso Admin</button>
    </div>

    <!-- Login Admin -->
    <div class="login" v-if="mostrarAdmin && !admin && !docente">
      <h2>Acceso Administrador</h2>
      <input v-model="usuarioAdmin" placeholder="Usuario" />
      <input
        v-model="passAdmin"
        type="password"
        placeholder="Contraseña"
        @keyup.enter="loginAdmin"
      />
      <button @click="loginAdmin">Ingresar</button>
      <button @click="mostrarAdmin = false">Cancelar</button>
      <p v-if="errorAdmin" class="error">{{ errorAdmin }}</p>
    </div>

    <!-- Vista principal docente -->
    <div v-else-if="docente" class="layout-docente">
      <div class="menu-docente">
        <h2>Bienvenido/a {{ docente.nombre }} {{ docente.apellido }}</h2>
        <div class="tile-botonera vertical">
          <button class="tile-btn" @click="pantalla = 'retirar'">Retirar equipo</button>
          <button class="tile-btn" @click="pantalla = 'devolver'">Devolver equipo</button>
          <button class="tile-btn" @click="pantalla = 'mantenimiento'">Marcar equipo</button>
          <button class="tile-btn" @click="pantalla = 'historial'">Ver historial</button>
          <button class="tile-btn" @click="logout">Salir</button>
        </div>
      </div>
      <div class="vista-docente">
        <RetirarEquipo v-if="pantalla === 'retirar'" :docente="docente" />
        <DevolverEquipo v-if="pantalla === 'devolver'" :docente="docente" />
        <MarcarMantenimiento v-if="pantalla === 'mantenimiento'" :docente="docente" />
        <HistorialDocente v-if="pantalla === 'historial'" :docente="docente" />
      </div>
    </div>

    <!-- Panel admin -->
    <div v-else-if="admin" class="layout-docente">
      <div class="menu-docente">
        <h2>Panel Administrador</h2>
        <div class="tile-botonera vertical">
          <button class="tile-btn" @click="pantallaAdmin = 'equipos'">Gestionar Equipos</button>
          <button class="tile-btn" @click="disponibilizarTodos">
            Marcar todos como disponibles
          </button>

          <button class="tile-btn" @click="pantallaAdmin = 'docentes'">Gestionar Docentes</button>
          <button class="tile-btn" @click="pantallaAdmin = 'historial'">Ver Historial</button>
          <button class="tile-btn" @click="logoutAdmin">Salir</button>
        </div>
      </div>
      <div class="vista-docente">
        <GestionEquipos v-if="pantallaAdmin === 'equipos'" />
        <GestionDocentes v-if="pantallaAdmin === 'docentes'" />
        <VerHistorial v-if="pantallaAdmin === 'historial'" />
      </div>
    </div>
  </div>
</template>

<script setup>
import GestionEquipos from './components/GestionEquipos.vue'
import GestionDocentes from './components/GestionDocentes.vue'
import VerHistorial from './components/VerHistorial.vue'
import RetirarEquipo from './components/RetirarEquipo.vue'
import DevolverEquipo from './components/DevolverEquipo.vue'
import MarcarMantenimiento from './components/MarcarMantenimiento.vue'
import HistorialDocente from './components/HistorialDocente.vue'
import { ref, onMounted, onUnmounted } from 'vue'
import axios from 'axios'

const dni = ref('')
const error = ref('')
const docente = ref(null)
var pantalla = ref('retirar')

const mostrarAdmin = ref(false)
const usuarioAdmin = ref('')
const passAdmin = ref('')
const errorAdmin = ref('')
const admin = ref(false)
const pantallaAdmin = ref('equipos')

const apiUrl = 'http://127.0.0.1:8000'

// Docente
const acceder = async () => {
  error.value = ''
  docente.value = null
  if (!dni.value) {
    error.value = 'Debe ingresar el DNI'
    return
  }
  try {
    const res = await axios.get(`${apiUrl}/docentes/`)
    const d = res.data.find((item) => item.dni === dni.value)
    if (d) {
      docente.value = d
      pantalla.value = 'retirar'
    } else {
      error.value = 'DNI no registrado'
    }
  } catch (e) {
    error.value = 'Error al conectar con el servidor | ' + e
  }
}

const logout = () => {
  docente.value = null
  dni.value = ''
  pantalla.value = 'retirar'
  error.value = ''
}

const loginAdmin = async () => {
  try {
    const res = await axios.post(`${apiUrl}/admin/login/`, {
      usuario: usuarioAdmin.value,
      password: passAdmin.value,
    })
    admin.value = res.data
    errorAdmin.value = ''
    pantallaAdmin.value = 'equipos'
    usuarioAdmin.value = ''
    passAdmin.value = ''
    mostrarAdmin.value = false
  } catch (e) {
    errorAdmin.value = 'Usuario o contraseña incorrectos | ' + e
  }
}

const logoutAdmin = () => {
  admin.value = false
  pantallaAdmin.value = 'equipos'
  usuarioAdmin.value = ''
  passAdmin.value = ''
  mostrarAdmin.value = false
  errorAdmin.value = ''
}

// --- INACTIVIDAD ---
let inactividadTimer = null

function cerrarPorInactividad() {
  docente.value = null
  dni.value = ''
  pantalla.value = 'retirar'
  error.value = ''
  admin.value = false
  pantallaAdmin.value = 'equipos'
  usuarioAdmin.value = ''
  passAdmin.value = ''
  mostrarAdmin.value = false
  errorAdmin.value = ''
}

function resetInactividad() {
  clearTimeout(inactividadTimer)
  // Solo reinicia el timer si hay sesión iniciada
  if (docente.value || admin.value) {
    inactividadTimer = setTimeout(() => {
      cerrarPorInactividad()
    }, 20000) // 20 segundos
  }
}

const disponibilizarTodos = async () => {
  try {
    const res = await axios.get(`${apiUrl}/equipos/`)
    const prestados = res.data.filter((e) => e.estado === 'prestado')

    if (prestados.length === 0) {
      alert('No hay equipos en estado "prestado".')
      return
    }

    const confirmacion = confirm(`¿Marcar ${prestados.length} equipo(s) como disponibles?`)
    if (!confirmacion) return

    await Promise.all(
      prestados.map((equipo) =>
        axios.put(`${apiUrl}/equipos/${equipo.id_equipo}`, {
          ...equipo,
          estado: 'disponible',
        }),
      ),
    )
    alert(`Se actualizaron ${prestados.length} equipo(s) a "disponible".`)
  } catch (e) {
    alert('Error al actualizar los equipos: ' + e)
  }
}

// Eventos a escuchar
const eventos = ['mousemove', 'mousedown', 'keydown', 'touchstart']

onMounted(() => {
  eventos.forEach((ev) => window.addEventListener(ev, resetInactividad))
  resetInactividad()
})

onUnmounted(() => {
  eventos.forEach((ev) => window.removeEventListener(ev, resetInactividad))
  clearTimeout(inactividadTimer)
})
</script>
