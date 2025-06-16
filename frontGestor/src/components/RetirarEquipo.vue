<template>
  <div>
    <h3>Retirar equipo</h3>

    <!-- Si hay curso seleccionado, aparece el resto -->
    <div v-if="cursoSeleccionado">
      <p><strong>Curso seleccionado:</strong> {{ curso }}</p>
      <form @submit.prevent="retirarPorCodigo" style="margin-bottom: 16px">
        <label for="codigo" style="margin-top: 10px">Ingresá el código del equipo:</label>
        <input
          v-model="codigo"
          placeholder="Identificador único"
          id="codigo"
          ref="codigoInput"
          @keyup.enter="retirarPorCodigo"
        />
      </form>

      <p style="margin: 14px 0 6px 0">O seleccioná un equipo de la lista:</p>
      <div class="equipo-lista">
        <div v-for="equipo in equipos" :key="equipo.id_equipo" class="equipo-card">
          <span>
            {{ equipo.nombre_equipo }} <b>({{ equipo.identificador_unico }})</b>
          </span>
          <button @click="retirarEquipo(equipo.id_equipo)">Retirar</button>
        </div>
      </div>

      <p v-if="mensaje" :style="{ color: mensajeColor, marginTop: '12px' }">{{ mensaje }}</p>
    </div>
    <div v-else>
      <!-- Selección de curso -->
      <form @submit.prevent="seleccionarCurso" style="margin-bottom: 16px">
        <label for="curso" style="margin-bottom: 5px; display: block">Seleccioná el curso:</label>
        <select v-model="curso" id="curso" required>
          <option disabled value="">Elegí curso...</option>
          <option v-for="c in cursos" :key="c" :value="c">{{ c }}</option>
        </select>
        <button type="submit" style="margin-top: 12px">Confirmar curso</button>
      </form>
    </div>
  </div>
</template>

<script setup>
import { ref, watch, onMounted, nextTick } from 'vue'
import axios from 'axios'

const props = defineProps({
  docente: { type: Object, required: true },
})

const apiUrl = 'http://127.0.0.1:8000'
const equipos = ref([])
const codigo = ref('')
const curso = ref('')
const cursoSeleccionado = ref(false)
const mensaje = ref('')
const mensajeColor = ref('green')
const codigoInput = ref(null)

const cursos = ['1A', '1B', '2A', '2B', '3A', '3B', '4A', '4B', '5A', '5B', '6A', '6B', '7A', '7B']

const seleccionarCurso = () => {
  if (curso.value) {
    localStorage.setItem('ultimoCurso', curso.value)
    cursoSeleccionado.value = true
    nextTick(() => codigoInput.value?.focus())
  }
}

const listarEquipos = async () => {
  const res = await axios.get(`${apiUrl}/equipos/`)
  equipos.value = res.data.filter((eq) => eq.estado === 'disponible')
}

const retirarPorCodigo = async () => {
  mensaje.value = ''
  const equipo = equipos.value.find((eq) => eq.identificador_unico === codigo.value)
  if (!equipo) {
    mensaje.value = 'No se encontró un equipo disponible con ese código.'
    mensajeColor.value = 'red'
    return
  }
  await retirarEquipo(equipo.id_equipo)
}

const retirarEquipo = async (id_equipo) => {
  try {
    await axios.post(`${apiUrl}/movimientos/retirar/`, {
      id_equipo,
      dni: props.docente.dni,
      observaciones: '',
      curso: curso.value,
    })
    mensaje.value = 'Equipo retirado correctamente.'
    mensajeColor.value = 'green'
    codigo.value = ''
    listarEquipos()
    nextTick(() => codigoInput.value?.focus())
  } catch (e) {
    mensaje.value = e.response?.data?.detail || 'Error al retirar equipo.'
    mensajeColor.value = 'red'
  }
}

// Cuando cambia el docente o se entra al componente
watch(
  () => props.docente,
  () => {
    mensaje.value = ''
    codigo.value = ''
    curso.value = ''
    cursoSeleccionado.value = false
    listarEquipos()
  },
)

onMounted(() => {
  mensaje.value = ''
  codigo.value = ''
  curso.value = ''
  cursoSeleccionado.value = false
  listarEquipos()
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
