<template>
  <div class="panel-docentes">
    <!-- Panel izquierdo: formulario -->
    <div class="panel-formulario">
      <h3>Agregar docente</h3>
      <form @submit.prevent="agregarDocente" class="form-docentes">
        <input v-model="nuevoDocente.nombre" placeholder="Nombre" required />
        <input v-model="nuevoDocente.apellido" placeholder="Apellido" required />
        <input v-model="nuevoDocente.dni" placeholder="DNI" required />
        <button type="submit">Agregar</button>
      </form>
    </div>

    <!-- Panel derecho: listado con filtros -->
    <div class="panel-listado">
      <h3>Docentes registrados</h3>

      <div class="filtros-docentes">
        <input v-model="filtroNombre" placeholder="Filtrar por nombre" />
        <input v-model="filtroApellido" placeholder="Filtrar por apellido" />
        <input v-model="filtroDNI" placeholder="Filtrar por DNI" />
      </div>

      <div class="tabla-scroll">
        <table border="1" cellpadding="6">
          <thead>
            <tr>
              <th>Nombre</th>
              <th>Apellido</th>
              <th>DNI</th>
              <th>Acciones</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="docente in docentesFiltrados" :key="docente.id_docente">
              <td>
                <input v-if="editId === docente.id_docente" v-model="editDocente.nombre" />
                <span v-else>{{ docente.nombre }}</span>
              </td>
              <td>
                <input v-if="editId === docente.id_docente" v-model="editDocente.apellido" />
                <span v-else>{{ docente.apellido }}</span>
              </td>
              <td>
                <input v-if="editId === docente.id_docente" v-model="editDocente.dni" />
                <span v-else>{{ docente.dni }}</span>
              </td>
              <td>
                <button
                  class="btn-tabla"
                  v-if="editId !== docente.id_docente"
                  @click="editarDocente(docente)"
                >
                  Editar
                </button>
                <button
                  class="btn-tabla"
                  v-if="editId === docente.id_docente"
                  @click="guardarEdicion(docente.id_docente)"
                >
                  Guardar
                </button>
                <button
                  class="btn-tabla"
                  v-if="editId === docente.id_docente"
                  @click="cancelarEdicion"
                >
                  Cancelar
                </button>
                <button
                  class="btn-tabla"
                  @click="eliminarDocente(docente.id_docente)"
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

const docentes = ref([])
const nuevoDocente = ref({ nombre: '', apellido: '', dni: '' })
const editId = ref(null)
const editDocente = ref({})
const mensaje = ref('')
const mensajeColor = ref('green')

const filtroNombre = ref('')
const filtroApellido = ref('')
const filtroDNI = ref('')

const listarDocentes = async () => {
  const res = await axios.get(`${apiUrl}/docentes/`)
  docentes.value = res.data
}

const agregarDocente = async () => {
  try {
    await axios.post(`${apiUrl}/docentes/`, nuevoDocente.value)
    mensaje.value = 'Docente agregado correctamente.'
    mensajeColor.value = 'green'
    nuevoDocente.value = { nombre: '', apellido: '', dni: '' }
    listarDocentes()
  } catch (e) {
    mensaje.value = 'Error al agregar docente (DNI repetido?) | ' + e
    mensajeColor.value = 'red'
  }
}

const editarDocente = (docente) => {
  editId.value = docente.id_docente
  editDocente.value = { ...docente }
}

const guardarEdicion = async (id) => {
  try {
    await axios.put(`${apiUrl}/docentes/${id}`, editDocente.value)
    mensaje.value = 'Docente modificado.'
    mensajeColor.value = 'green'
    editId.value = null
    listarDocentes()
  } catch (e) {
    mensaje.value = 'Error al modificar docente. | ' + e
    mensajeColor.value = 'red'
  }
}

const cancelarEdicion = () => {
  editId.value = null
  editDocente.value = {}
}

const eliminarDocente = async (id) => {
  if (confirm('¿Eliminar docente?')) {
    try {
      await axios.delete(`${apiUrl}/docentes/${id}`)
      mensaje.value = 'Docente eliminado.'
      mensajeColor.value = 'green'
      listarDocentes()
    } catch (e) {
      mensaje.value = 'Error al eliminar docente. | ' + e
      mensajeColor.value = 'red'
    }
  }
}

const docentesFiltrados = computed(() =>
  docentes.value.filter((d) => {
    const nombreOk = d.nombre.toLowerCase().includes(filtroNombre.value.toLowerCase())
    const apellidoOk = d.apellido.toLowerCase().includes(filtroApellido.value.toLowerCase())
    const dniOk = d.dni.toLowerCase().includes(filtroDNI.value.toLowerCase())
    return nombreOk && apellidoOk && dniOk
  }),
)

onMounted(listarDocentes)
</script>

<style scoped>
.panel-docentes {
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

.form-docentes {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.filtros-docentes {
  display: flex;
  gap: 10px;
  margin-bottom: 10px;
  flex-wrap: wrap;
  justify-content: center;
}

.tabla-scroll {
  max-height: 320px;
  overflow-y: auto;
  overflow-x: auto;
  border-radius: 12px;
  box-shadow: 0 1px 10px rgba(0, 0, 0, 0.05);
  width: 100%;
}

table {
  min-width: 200px;
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
  min-width: 100px;
}
</style>
