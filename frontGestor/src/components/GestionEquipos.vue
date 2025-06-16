<template>
  <div class="panel-equipos">
    <!-- Panel izquierdo: formulario -->
    <div class="panel-formulario">
      <h3>Agregar equipo</h3>
      <form @submit.prevent="agregarEquipo" class="form-equipos">
        <input v-model="nuevoEquipo.nombre_equipo" placeholder="Nombre del equipo" required />
        <input
          v-model="nuevoEquipo.identificador_unico"
          placeholder="Identificador único"
          required
        />
        <select v-model="nuevoEquipo.estado">
          <option value="disponible">Disponible</option>
          <option value="mantenimiento">Mantenimiento</option>
        </select>
        <button type="submit">Agregar</button>
      </form>
    </div>

    <!-- Panel derecho: listado con filtros -->
    <div class="panel-listado">
      <h3>Equipos registrados</h3>

      <div class="filtros-equipos">
        <input v-model="filtroNombre" placeholder="Filtrar por nombre" />
        <input v-model="filtroIdentificador" placeholder="Por identificador" />
        <select v-model="filtroEstado">
          <option value="">Todos</option>
          <option value="disponible">Disponible</option>
          <option value="prestado">Prestado</option>
          <option value="mantenimiento">Mantenimiento</option>
        </select>
      </div>

      <div class="tabla-scroll">
        <table border="1" cellpadding="6">
          <thead>
            <tr>
              <th>Nombre</th>
              <th>Identificador</th>
              <th>Estado</th>
              <th>Acciones</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="equipo in equiposFiltrados" :key="equipo.id_equipo">
              <td>
                <input v-if="editId === equipo.id_equipo" v-model="editEquipo.nombre_equipo" />
                <span v-else>{{ equipo.nombre_equipo }}</span>
              </td>
              <td>
                <input
                  v-if="editId === equipo.id_equipo"
                  v-model="editEquipo.identificador_unico"
                />
                <span v-else>{{ equipo.identificador_unico }}</span>
              </td>
              <td>
                <select v-if="editId === equipo.id_equipo" v-model="editEquipo.estado">
                  <option value="disponible">Disponible</option>
                  <option value="prestado">Prestado</option>
                  <option value="mantenimiento">Mantenimiento</option>
                </select>
                <span v-else>{{ equipo.estado }}</span>
              </td>
              <td>
                <button
                  class="btn-tabla"
                  v-if="editId !== equipo.id_equipo"
                  @click="editarEquipo(equipo)"
                >
                  Editar
                </button>
                <button
                  class="btn-tabla"
                  v-if="editId === equipo.id_equipo"
                  @click="guardarEdicion(equipo.id_equipo)"
                >
                  Guardar
                </button>
                <button
                  class="btn-tabla"
                  v-if="editId === equipo.id_equipo"
                  @click="cancelarEdicion"
                >
                  Cancelar
                </button>
                <button
                  class="btn-tabla"
                  @click="eliminarEquipo(equipo.id_equipo)"
                  style="margin-left: 6px; color: #d50000"
                >
                  Eliminar
                </button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>

      <p v-if="mensaje" :style="{ color: mensajeColor, marginTop: '10px', textAlign: 'center' }">
        {{ mensaje }}
      </p>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import axios from 'axios'

const apiUrl = 'http://127.0.0.1:8000'

const equipos = ref([])
const nuevoEquipo = ref({ nombre_equipo: '', identificador_unico: '', estado: 'disponible' })
const editId = ref(null)
const editEquipo = ref({})
const mensaje = ref('')
const mensajeColor = ref('green')

const filtroNombre = ref('')
const filtroIdentificador = ref('')
const filtroEstado = ref('')

const listarEquipos = async () => {
  const res = await axios.get(`${apiUrl}/equipos/`)
  equipos.value = res.data
}

const agregarEquipo = async () => {
  try {
    await axios.post(`${apiUrl}/equipos/`, nuevoEquipo.value)
    mensaje.value = 'Equipo agregado correctamente.'
    mensajeColor.value = 'green'
    nuevoEquipo.value = { nombre_equipo: '', identificador_unico: '', estado: 'disponible' }
    listarEquipos()
  } catch (e) {
    mensaje.value = 'Error al agregar equipo (identificador repetido?) | ' + e
    mensajeColor.value = 'red'
  }
}

const editarEquipo = (equipo) => {
  editId.value = equipo.id_equipo
  editEquipo.value = { ...equipo }
}

const guardarEdicion = async (id) => {
  try {
    await axios.put(`${apiUrl}/equipos/${id}`, editEquipo.value)
    mensaje.value = 'Equipo modificado.'
    mensajeColor.value = 'green'
    editId.value = null
    listarEquipos()
  } catch (e) {
    mensaje.value = 'Error al modificar equipo. | ' + e
    mensajeColor.value = 'red'
  }
}

const cancelarEdicion = () => {
  editId.value = null
  editEquipo.value = {}
}

const eliminarEquipo = async (id) => {
  if (confirm('¿Eliminar equipo?')) {
    try {
      await axios.delete(`${apiUrl}/equipos/${id}`)
      mensaje.value = 'Equipo eliminado.'
      mensajeColor.value = 'green'
      listarEquipos()
    } catch (e) {
      mensaje.value = 'Error al eliminar equipo. | ' + e
      mensajeColor.value = 'red'
    }
  }
}

const equiposFiltrados = computed(() =>
  equipos.value.filter((e) => {
    const nombreOk = e.nombre_equipo.toLowerCase().includes(filtroNombre.value.toLowerCase())
    const identOk = e.identificador_unico
      .toLowerCase()
      .includes(filtroIdentificador.value.toLowerCase())
    const estadoOk = filtroEstado.value === '' || e.estado === filtroEstado.value
    return nombreOk && identOk && estadoOk
  }),
)

onMounted(listarEquipos)
</script>

<style scoped>
.tabla-scroll {
  max-height: 320px;
  overflow-y: auto;
  overflow-x: auto;
  border-radius: 12px;
  box-shadow: 0 1px 10px rgba(0, 0, 0, 0.05);
  width: 100%;
}

table {
  min-width: 200px; /* Asegura espacio para las columnas */
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

.btn-tabla {
  width: 90px;
}

td:last-child button {
  margin: 2px;
  white-space: nowrap;
}

td:last-child {
  min-width: 100px; /* Asegura espacio para los 3-4 botones */
}

.panel-equipos {
  display: flex;
  gap: 24px;
  padding: 16px;
  flex-wrap: wrap;
  justify-content: center;
}

.panel-formulario,
.panel-listado {
  background: #fff;
  border-radius: 16px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.07);
  padding: 20px;
  flex: 1 1 400px;
  max-width: 700px;
}

.form-equipos {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.filtros-equipos {
  display: flex;
  gap: 10px;
  margin-bottom: 10px;
  flex-wrap: wrap;
  justify-content: center;
}
</style>
