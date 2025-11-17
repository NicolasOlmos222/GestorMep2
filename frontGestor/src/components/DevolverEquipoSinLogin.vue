<template>
  <div>
    <h3>Devolver equipo</h3>

    <form @submit.prevent="buscarEquipoPorCodigo" style="margin-bottom: 16px">
      <label for="codigo">Escaneá o ingresá el código del equipo:</label>
      <input
        v-model="codigo"
        placeholder="Identificador único"
        id="codigo"
        ref="codigoInput"
        @keyup.enter="buscarEquipoPorCodigo"
      />
    </form>

    <div v-if="equipoSeleccionado && docente">
      <p><b>Docente:</b> {{ docente.nombre }} {{ docente.apellido }}</p>
      <p><b>Curso:</b> {{ equipoSeleccionado.curso }}</p>

      <p style="margin-top: 12px">Equipos en préstamo:</p>
      <div class="equipo-lista">
        <div v-for="mov in prestamos" :key="mov.id_movimiento" class="equipo-card">
          <span>
            {{ mov.nombre_equipo }} <b>({{ mov.identificador_unico }})</b>
          </span>
          <button @click="devolverEquipo(mov.id_movimiento)">Devolver</button>
        </div>
      </div>
    </div>

    <p v-if="mensaje" :style="{ color: mensajeColor, marginTop: '12px' }">{{ mensaje }}</p>
  </div>
</template>

<script setup>
import { ref, onMounted, nextTick } from 'vue'
import axios from 'axios'

const loading = ref(false)

const apiUrl = 'http://127.0.0.1:8000'

const codigo = ref('')
const equipoSeleccionado = ref(null)
const docente = ref(null)
const prestamos = ref([])
const mensaje = ref('')
const mensajeColor = ref('green')
const codigoInput = ref(null)
const busquedaExitosa = ref(false)

const guardarEnLocalStorage = () => {
  localStorage.setItem('docente_devolucion', JSON.stringify(docente.value))
  localStorage.setItem('prestamos_devolucion', JSON.stringify(prestamos.value))
  localStorage.setItem('equipo_seleccionado', JSON.stringify(equipoSeleccionado.value))
}

const cargarDesdeLocalStorage = () => {
  const docenteGuardado = localStorage.getItem('docente_devolucion')
  const prestamosGuardados = localStorage.getItem('prestamos_devolucion')
  const equipoGuardado = localStorage.getItem('equipo_seleccionado')

  if (docenteGuardado && prestamosGuardados && equipoGuardado) {
    docente.value = JSON.parse(docenteGuardado)
    prestamos.value = JSON.parse(prestamosGuardados)
    equipoSeleccionado.value = JSON.parse(equipoGuardado)
    busquedaExitosa.value = true
  }
}
const buscarEquipoPorCodigo = async () => {
  if (loading.value || !codigo.value.trim()) return

  mensaje.value = ''
  busquedaExitosa.value = false
  loading.value = true

  try {
    const res = await axios.get(`${apiUrl}/movimientos/`)
    const movimientos = res.data

    const codigoBuscado = codigo.value.trim().toLowerCase()

    const mov = movimientos.find(
      (m) =>
        m.identificador_unico.toLowerCase() === codigoBuscado &&
        !m.fecha_hora_devolucion &&
        m.estado !== 'mantenimiento',
    )

    if (!mov) {
      mensaje.value = 'Equipo no encontrado o ya devuelto.'
      mensajeColor.value = 'red'
      codigo.value = ''
      return
    }

    equipoSeleccionado.value = mov
    docente.value = {
      nombre: mov.nombre_docente,
      apellido: mov.apellido_docente,
    }

    prestamos.value = movimientos.filter(
      (m) =>
        m.nombre_docente === docente.value.nombre &&
        m.apellido_docente === docente.value.apellido &&
        !m.fecha_hora_devolucion &&
        m.estado !== 'mantenimiento',
    )

    mensaje.value = ''
    mensajeColor.value = 'green'
    busquedaExitosa.value = true
    guardarEnLocalStorage()
    codigo.value = ''

    devolverEquipo(mov.id_movimiento)
  } catch (e) {
    mensaje.value = 'Error al buscar el equipo. | ' + e
    mensajeColor.value = 'red'
    codigo.value = ''
  } finally {
    loading.value = false
    nextTick(() => codigoInput.value?.focus())
  }
}

const devolverEquipo = async (id_movimiento) => {
  try {
    await axios.post(`${apiUrl}/movimientos/devolver/`, {
      id_movimiento,
    })

    mensaje.value = 'Equipo devuelto correctamente.'
    mensajeColor.value = 'green'

    // Remover el equipo devuelto de la lista
    prestamos.value = prestamos.value.filter((p) => p.id_movimiento !== id_movimiento)

    // Actualizar el almacenamiento local con la nueva lista
    localStorage.setItem('prestamos_devolucion', JSON.stringify(prestamos.value))
  } catch (e) {
    mensaje.value = e.response?.data?.detail || 'Error al devolver equipo.'
    mensajeColor.value = 'red'
  }
}

onMounted(() => {
  cargarDesdeLocalStorage()
  nextTick(() => codigoInput.value?.focus())
})
</script>

<style scoped>
.equipo-lista {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
  gap: 12px;
  max-height: 340px;
  overflow-y: auto;
  margin-top: 12px;
  padding-right: 8px;
}

.equipo-card {
  background: #f8fbff;
  padding: 12px;
  border-radius: 10px;
  box-shadow: 0 1px 6px rgba(0, 0, 0, 0.07);
  display: flex;
  justify-content: space-between;
  align-items: center;
}
</style>
