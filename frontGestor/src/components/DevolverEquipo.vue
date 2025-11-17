<template>
  <div>
    <h3>Devolver equipo</h3>

    <form @submit.prevent="devolverPorCodigo" style="margin-bottom: 16px">
      <label for="codigo">Ingresá el código del equipo a devolver:</label>
      <input
        v-model="codigo"
        placeholder="Identificador único"
        id="codigo"
        ref="codigoInput"
        @keyup.enter="devolverPorCodigo"
      />
    </form>

    <p style="margin: 14px 0 0 0">O seleccioná un equipo de la lista:</p>
    <div class="equipo-lista">
      <div v-for="mov in prestamos" :key="mov.id_movimiento" class="equipo-card">
        <span>
          {{ mov.nombre_equipo }} <b>({{ mov.identificador_unico }})</b>
        </span>
        <button @click="devolverEquipo(mov.id_movimiento)">Devolver</button>
      </div>
    </div>

    <p v-if="mensaje" :style="{ color: mensajeColor, marginTop: '12px' }">{{ mensaje }}</p>
  </div>
</template>

<script setup>
import { ref, onMounted, watch, nextTick } from 'vue'
import axios from 'axios'
const loading = ref(false)

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

const devolverPorCodigo = async () => {
  if (loading.value || !codigo.value.trim()) return

  mensaje.value = ''
  const mov = prestamos.value.find(
    (p) => p.identificador_unico.toLowerCase() === codigo.value.trim().toLowerCase(),
  )

  if (!mov) {
    mensaje.value = 'No se encontró un equipo prestado con ese código.'
    mensajeColor.value = 'red'
    codigo.value = ''
    return
  }

  await devolverEquipo(mov.id_movimiento)
}

const devolverEquipo = async (id_movimiento) => {
  loading.value = true
  try {
    await axios.post(`${apiUrl}/movimientos/devolver/`, {
      id_movimiento,
    })

    mensaje.value = 'Equipo devuelto correctamente.'
    mensajeColor.value = 'green'
    codigo.value = ''

    await listarPrestamos()
    nextTick(() => codigoInput.value?.focus())
  } catch (e) {
    mensaje.value = e.response?.data?.detail || 'Error al devolver equipo.'
    mensajeColor.value = 'red'
    codigo.value = ''
  } finally {
    loading.value = false
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
