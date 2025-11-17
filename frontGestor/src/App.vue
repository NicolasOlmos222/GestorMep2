<template>
  <div class="container">
    <!-- Pantalla principal -->
    <div v-if="!pantalla">
      <h2>Gestión de Equipos</h2>
      <div class="menu-principal">
        <button class="tile-btn" @click="pantalla = 'retirar'">Retirar equipo</button>
        <button class="tile-btn" @click="pantalla = 'devolver'">Devolver equipo</button>
      </div>
    </div>

    <!-- Retirar equipo (pide DNI primero) -->
    <div v-else-if="pantalla === 'retirar' && !docente">
      <h3>Ingreso de Docente</h3>
      <input v-model="dni" placeholder="Ingrese su DNI" @keyup.enter="acceder" />
      <button class="tile-btn" @click="acceder">Acceder</button>
      <p v-if="error" class="error">{{ error }}</p>
      <button class="tile-btn" @click="volver">Volver</button>
    </div>

    <!-- Retirar equipo (ya logueado) -->
    <div v-else-if="pantalla === 'retirar' && docente">
      <button class="tile-btn" @click="logout">Salir</button>
      <h3>Bienvenido/a {{ docente.nombre }} {{ docente.apellido }}</h3>
      <RetirarEquipo :docente="docente" />
    </div>

    <!-- Devolver equipo (sin login) -->
    <div v-else-if="pantalla === 'devolver'">
      <button class="tile-btn" @click="volver">Volver</button>
      <DevolverEquipoSinLogin />
    </div>

    <!-- Admin -->
    <div v-else-if="pantalla === 'admin'">
      <button class="tile-btn" @click="volver">Volver</button>
      <h3>Panel de Admin</h3>
      <button class="tile-btn" @click="pantalla2 = 'ver-historial'">Ver historial</button>
      <button class="tile-btn" @click="pantalla2 = 'gestion-docentes'">Gestionar docentes</button>
      <button class="tile-btn" @click="pantalla2 = 'gestion-equipos'">Gestionar equipos</button>

      <VerHistorial v-if="pantalla2 === 'ver-historial'" />
      <GestionDocentes v-else-if="pantalla2 === 'gestion-docentes'" />
      <GestionEquipos v-else-if="pantalla2 === 'gestion-equipos'" />
    </div>
  </div>

  <p>~~ V3.1 ~~</p>
  <button class="btn-button" @click="pantalla = 'admin'">Admin</button>
</template>

<script setup>
import { ref, onMounted, onUnmounted } from 'vue'
import axios from 'axios'
import RetirarEquipo from './components/RetirarEquipo.vue'
import DevolverEquipoSinLogin from './components/DevolverEquipoSinLogin.vue'
import VerHistorial from './components/VerHistorial.vue'
import GestionDocentes from './components/GestionDocentes.vue'
import GestionEquipos from './components/GestionEquipos.vue'

const apiUrl = 'http://127.0.0.1:8000'

const pantalla = ref(null)
const pantalla2 = ref(null)
const docente = ref(null)
const dni = ref('')
const error = ref('')

// --- LOGIN DOCENTE ---
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
  error.value = ''
  pantalla.value = null
  pantalla2.value = null
}

const volver = () => {
  logout()
}

// --- INACTIVIDAD ---
let inactividadTimer = null

function cerrarPorInactividad() {
  logout()
}

function resetInactividad() {
  clearTimeout(inactividadTimer)
  if (docente.value) {
    inactividadTimer = setTimeout(() => {
      cerrarPorInactividad()
    }, 30000) // ⏱ 1 minuto (podés cambiar el tiempo acá)
  }
}

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

<style>
p {
  text-align: center;
}
.btn-button {
  width: 50px;
  position: absolute;
  top: 10px;
  right: 10px;
  border: none;
  border-radius: 6px;
  background-color: #4e73df;
  color: white;
  font-size: 16px;
  cursor: pointer;
}
.container {
  text-align: center;
  padding: 20px;
}

.menu-principal {
  display: flex;
  flex-direction: column;
  gap: 12px;
  margin-top: 20px;
}

.tile-btn {
  padding: 12px 20px;
  margin-left: 5%;
  border: none;
  border-radius: 6px;
  background-color: #4e73df;
  color: white;
  font-size: 16px;
  cursor: pointer;
}

.tile-btn:hover {
  background-color: #2e59d9;
}

.error {
  color: red;
  margin-top: 10px;
}
</style>
