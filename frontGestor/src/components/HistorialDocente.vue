<template>
  <div>
    <h3>Mi historial de hoy</h3>

    <div class="tabla-scroll" v-if="historial.length > 0">
      <table border="1" cellpadding="6">
        <thead>
          <tr>
            <th>Equipo</th>
            <th>Acción</th>
            <th>Hora retiro</th>
            <th>Hora devolución</th>
            <th>Curso</th>
            <th>Docente</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="mov in historial" :key="mov.id_movimiento">
            <td>
              {{ mov.nombre_equipo }}
              <span v-if="mov.identificador_unico">({{ mov.identificador_unico }})</span>
            </td>
            <td>
              <span v-if="mov.estado === 'mantenimiento'">Mantenimiento</span>
              <span v-else-if="!mov.fecha_hora_devolucion">Retirado</span>
              <span v-else>Devuelto</span>
            </td>
            <td>{{ mov.fecha_hora_retiro ? horaLocal(mov.fecha_hora_retiro) : '-' }}</td>
            <td>{{ mov.fecha_hora_devolucion ? horaLocal(mov.fecha_hora_devolucion) : '-' }}</td>
            <td>{{ mov.curso }}</td>
            <td>{{ mov.nombre_docente }} {{ mov.apellido_docente }}</td>
          </tr>
        </tbody>
      </table>
    </div>

    <p v-else>No tenés movimientos registrados hoy.</p>
  </div>
</template>

<script setup>
import { ref, onMounted, watch } from 'vue'
import axios from 'axios'

const props = defineProps({
  docente: { type: Object, required: true },
})

const apiUrl = 'http://127.0.0.1:8000'
const historial = ref([])

const hoy = () => {
  const f = new Date()
  return `${f.getFullYear()}-${(f.getMonth() + 1).toString().padStart(2, '0')}-${f.getDate().toString().padStart(2, '0')}`
}

const cargarHistorial = async () => {
  const res = await axios.get(`${apiUrl}/movimientos/`)
  historial.value = res.data
    .filter(
      (mov) =>
        (mov.fecha_hora_retiro && mov.fecha_hora_retiro.startsWith(hoy())) ||
        (mov.fecha_hora_devolucion && mov.fecha_hora_devolucion.startsWith(hoy())),
    )
    .map((mov) => ({
      ...mov,
      estado: mov.estado || (mov.fecha_hora_devolucion ? 'devuelto' : 'prestado'),
    }))
}

const horaLocal = (fechaStr) => {
  if (!fechaStr) return ''
  const d = new Date(fechaStr)
  return d.toLocaleTimeString('es-AR', { hour: '2-digit', minute: '2-digit' })
}

watch(() => props.docente, cargarHistorial)
onMounted(cargarHistorial)
</script>

<style scoped>
.tabla-scroll {
  max-height: 360px;
  overflow-y: auto;
  overflow-x: auto;
  margin: 0 auto;
  border-radius: 12px;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.08);
  width: fit-content;
  max-width: 95vw;
}

table {
  width: 100%;
  border-collapse: collapse;
  background: #fff;
}

th,
td {
  padding: 10px;
  text-align: center;
  white-space: nowrap;
  border: 1px solid #dce3f0;
}
</style>
