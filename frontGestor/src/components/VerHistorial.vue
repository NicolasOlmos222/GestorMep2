<template>
  <div class="panel-historial">
    <h3>Historial de movimientos</h3>

    <div class="filtros-historial">
      <input v-model="filtroEquipo" placeholder="Filtrar por equipo" />
      <input v-model="filtroDocente" placeholder="Filtrar por docente" />
      <input v-model="filtroDia" type="date" />
      <select v-model="filtroEstado">
        <option value="">Todos</option>
        <option value="prestado">Prestado</option>
        <option value="devuelto">Devuelto</option>
        <option value="mantenimiento">Mantenimiento</option>
      </select>
      <button @click="exportarExcel">Exportar a Excel</button>
    </div>

    <div class="tabla-scroll">
      <table v-if="historialFiltrado.length > 0" border="1" cellpadding="6">
        <thead>
          <tr>
            <th>Equipo</th>
            <th>Código</th>
            <th>Curso</th>
            <th>Docente</th>
            <th>Retiro</th>
            <th>Devolución</th>
            <th>Estado</th>
            <th>Observaciones</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="mov in historialFiltrado" :key="mov.id_movimiento">
            <td>{{ mov.nombre_equipo }}</td>
            <td>{{ mov.identificador_unico }}</td>
            <td>{{ mov.curso }}</td>
            <td>{{ mov.nombre_docente }} {{ mov.apellido_docente }}</td>
            <td>{{ formatFecha(mov.fecha_hora_retiro) }}</td>
            <td>{{ mov.fecha_hora_devolucion ? formatFecha(mov.fecha_hora_devolucion) : '-' }}</td>
            <td>
              <span v-if="mov.estado === 'mantenimiento'">Mantenimiento</span>
              <span v-else-if="!mov.fecha_hora_devolucion">Prestado</span>
              <span v-else>Devuelto</span>
            </td>
            <td>{{ mov.observaciones }}</td>
          </tr>
        </tbody>
      </table>
      <p v-else>No hay movimientos registrados.</p>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import axios from 'axios'
import * as XLSX from 'xlsx'

const apiUrl = 'http://127.0.0.1:8000'
const historial = ref([])

const filtroEquipo = ref('')
const filtroDocente = ref('')
filtroDocente.value = ''
const filtroDia = ref('')
const filtroEstado = ref('')

const cargarHistorial = async () => {
  const res = await axios.get(`${apiUrl}/movimientos/`)
  historial.value = res.data.map((mov) => ({
    ...mov,
    estado:
      mov.estado ||
      (mov.fecha_hora_devolucion
        ? 'devuelto'
        : mov.estado === 'mantenimiento'
          ? 'mantenimiento'
          : 'prestado'),
  }))
}

const formatFecha = (fechaStr) => {
  if (!fechaStr) return ''
  const fecha = new Date(fechaStr)
  return fecha.toLocaleString('es-AR', { dateStyle: 'short', timeStyle: 'short' })
}

const historialFiltrado = computed(() =>
  historial.value.filter((m) => {
    const equipoOk = m.nombre_equipo.toLowerCase().includes(filtroEquipo.value.toLowerCase())
    const docenteOk = `${m.nombre_docente} ${m.apellido_docente}`
      .toLowerCase()
      .includes(filtroDocente.value.toLowerCase())
    const estadoOk = filtroEstado.value === '' || m.estado === filtroEstado.value
    const fechaOk =
      !filtroDia.value ||
      (m.fecha_hora_retiro && m.fecha_hora_retiro.startsWith(filtroDia.value)) ||
      (m.fecha_hora_devolucion && m.fecha_hora_devolucion.startsWith(filtroDia.value))
    return equipoOk && docenteOk && estadoOk && fechaOk
  }),
)

const exportarExcel = () => {
  const ws = XLSX.utils.json_to_sheet(
    historialFiltrado.value.map((m) => ({
      Equipo: m.nombre_equipo,
      Codigo: m.identificador_unico,
      Curso: m.curso,
      Docente: `${m.nombre_docente} ${m.apellido_docente}`,
      Retiro: formatFecha(m.fecha_hora_retiro),
      Devolucion: formatFecha(m.fecha_hora_devolucion),
      Estado: m.estado,
      Observaciones: m.observaciones,
    })),
  )
  const wb = XLSX.utils.book_new()
  XLSX.utils.book_append_sheet(wb, ws, 'Historial')
  XLSX.writeFile(wb, 'historial_equipos.xlsx')
}

onMounted(cargarHistorial)
</script>

<style scoped>
.panel-historial {
  padding: 6px;
  background: #fff;
  border-radius: 16px;
  max-width: 1000px;
  margin: auto;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
}

.filtros-historial {
  display: flex;
  gap: 12px;
  margin-bottom: 14px;
  flex-wrap: wrap;
  justify-content: center;
}

.tabla-scroll {
  max-height: 440px;
  overflow-y: auto;
  overflow-x: auto;
  border-radius: 12px;
  box-shadow: 0 1px 10px rgba(0, 0, 0, 0.05);
}

th,
td {
  padding: 10px;
  text-align: center;
  white-space: nowrap;
  border: 1px solid #dce3f0;
}

button {
  padding: 6px 12px;
  background: #2e7d32;
  color: #fff;
  border: none;
  border-radius: 6px;
  cursor: pointer;
}
</style>
