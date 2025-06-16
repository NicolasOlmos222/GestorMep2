<template>
  <div>
    <h3>Marcar equipo en mantenimiento</h3>

    <form @submit.prevent="marcarPorCodigo" style="margin-bottom: 16px">
      <label for="codigo">Ingresá el código del equipo:</label>
      <input
        v-model="codigo"
        placeholder="Identificador único"
        id="codigo"
        ref="codigoInput"
        @keyup.enter="marcarPorCodigo"
      />
    </form>

    <p style="margin: 14px 0 0 0">O seleccioná un equipo de la lista:</p>
    <div class="equipo-lista">
      <div v-for="mov in prestamos" :key="mov.id_movimiento" class="equipo-card">
        <span>
          {{ mov.nombre_equipo }} <b>({{ mov.identificador_unico }})</b>
        </span>
        <button @click="marcarMantenimiento(mov.id_equipo)">Marcar</button>
      </div>
    </div>

    <p v-if="mensaje" :style="{ color: mensajeColor, marginTop: '12px' }">{{ mensaje }}</p>
  </div>
</template>

<script setup>
import { ref, watch, onMounted, nextTick } from 'vue'
import axios from 'axios'

const props = defineProps({
  docente: { type: Object, required: true },
})

const apiUrl = 'http://127.0.0.1:8000'
const prestamos = ref([])
const codigo = ref('')
const mensaje = ref('')
const mensajeColor = ref('green')
const codigoInput = ref(null)

const listarPrestamos = async () => {
  const res = await axios.get(`${apiUrl}/movimientos/`)
  prestamos.value = res.data.filter(
    (mov) =>
      mov.nombre_docente === props.docente.nombre &&
      mov.apellido_docente === props.docente.apellido &&
      !mov.fecha_hora_devolucion &&
      mov.estado !== 'mantenimiento',
  )
}

const marcarPorCodigo = async () => {
  mensaje.value = ''
  const mov = prestamos.value.find((p) => p.identificador_unico === codigo.value)
  if (!mov) {
    mensaje.value = 'No se encontró un equipo retirado con ese código.'
    mensajeColor.value = 'red'
    return
  }
  await marcarMantenimiento(mov.id_equipo)
  codigo.value = ''
  nextTick(() => codigoInput.value?.focus())
}

const marcarMantenimiento = async (id_equipo) => {
  try {
    await axios.post(`${apiUrl}/equipos/mantenimiento/`, { id_equipo })
    mensaje.value = 'Equipo marcado en mantenimiento.'
    mensajeColor.value = 'green'
    listarPrestamos()
  } catch (e) {
    mensaje.value = e.response?.data?.detail || 'Error al marcar mantenimiento.'
    mensajeColor.value = 'red'
  }
}

watch(
  () => props.docente,
  () => {
    mensaje.value = ''
    codigo.value = ''
    listarPrestamos()
    nextTick(() => codigoInput.value?.focus())
  },
)

onMounted(() => {
  listarPrestamos()
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
