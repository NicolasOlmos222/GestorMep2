<template>
  <div class="layout-retirar">
    <!-- Columna izquierda: Escaneo + préstamos -->
    <div class="columna izquierda">
      <h3>Escanear equipo</h3>
      <form @submit.prevent="retirarPorCodigo">
        <label for="codigo">Ingresá o escaneá el código:</label>
        <input
          v-model="codigo"
          placeholder="Identificador único"
          id="codigo"
          ref="codigoInput"
          @keyup.enter="retirarPorCodigo"
        />
        <button type="submit">Retirar por código</button>
      </form>

      <p v-if="mensaje" :style="{ color: mensajeColor, marginTop: '12px' }">{{ mensaje }}</p>

      <h4 style="margin-top:20px">Tus equipos en préstamo</h4>
      <ul v-if="prestamos.length > 0" class="lista-prestamos">
        <li v-for="mov in prestamos" :key="mov.id_movimiento">
          {{ mov.nombre_equipo }} ({{ mov.identificador_unico }})
        </li>
      </ul>
      <p v-else>No tenés equipos en préstamo.</p>
    </div>

    <!-- Columna derecha: selección manual -->
    <div class="columna derecha">
      <h3>Seleccionar manualmente</h3>
      <div class="equipo-lista">
        <div v-for="equipo in equipos" :key="equipo.id_equipo" class="equipo-card">
          <span>
            {{ equipo.nombre_equipo }} <b>({{ equipo.identificador_unico }})</b>
          </span>
          <button @click="retirarEquipo(equipo)">Retirar</button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, nextTick } from 'vue'
import axios from 'axios'

const props = defineProps({
  docente: { type: Object, required: true },
})

const apiUrl = 'http://127.0.0.1:8000'
const equipos = ref([])
const prestamos = ref([])
const codigo = ref('')
const mensaje = ref('')
const mensajeColor = ref('green')
const codigoInput = ref(null)

const listarEquipos = async () => {
  const res = await axios.get(`${apiUrl}/equipos/`)
  equipos.value = res.data.filter((eq) => eq.estado === 'disponible')

  const resMov = await axios.get(`${apiUrl}/movimientos/`)
  prestamos.value = resMov.data.filter(
    (m) => m.dni_docente === props.docente.dni && !m.fecha_hora_devolucion
  )
}


const retirarPorCodigo = async () => {
  if (!codigo.value.trim()) return
  const codigoBuscado = codigo.value.trim().toLowerCase()

  const resEquipos = await axios.get(`${apiUrl}/equipos/`)
  const equipo = resEquipos.data.find(
    (eq) => eq.identificador_unico.toLowerCase() === codigoBuscado
  )

  if (!equipo) {
    mensaje.value = 'No se encontró el equipo.'
    mensajeColor.value = 'red'
    codigo.value = ''
    return
  }

  await retirarEquipo(equipo)
}

const retirarEquipo = async (equipo) => {
  try {
    // Buscar movimientos activos
    const resMov = await axios.get(`${apiUrl}/movimientos/`)
    const movActivo = resMov.data.find(
      (m) =>
        m.id_equipo === equipo.id_equipo &&
        !m.fecha_hora_devolucion &&
        m.estado !== 'mantenimiento'
    )

    if (movActivo) {
      if (movActivo.dni_docente === props.docente.dni) {
        // Ya lo tiene el mismo docente
        mensaje.value = 'Ya tenés este equipo reservado.'
        mensajeColor.value = 'orange'
        codigo.value = ''
        return
      } else {
        // Estaba reservado por otro docente → se devuelve automáticamente
        await axios.post(`${apiUrl}/movimientos/devolver/`, {
          id_movimiento: movActivo.id_movimiento,
        })
        console.log('Equipo devuelto automáticamente del docente anterior')
      }
    }

    // Ahora lo retiramos para el docente actual
    await axios.post(`${apiUrl}/movimientos/retirar/`, {
      id_equipo: equipo.id_equipo,
      dni: props.docente.dni,
      observaciones: '',
      curso: '---', // si no usás curso, lo dejamos genérico
    })

    mensaje.value = 'Equipo retirado correctamente.'
    mensajeColor.value = 'green'
    codigo.value = ''
    await listarEquipos()
    nextTick(() => codigoInput.value?.focus())
  } catch (e) {
    mensaje.value = e.response?.data?.detail || 'quipo retirado correctamente.'
    mensajeColor.value = 'red'
    codigo.value = ''
  }
}

onMounted(() => {
  listarEquipos()
  nextTick(() => codigoInput.value?.focus())
})
</script>

<style scoped>
.layout-retirar {
  display: grid;
  grid-template-columns: 1fr 2fr; /* izquierda más angosta, derecha más grande */
  gap: 24px;
  width: 100%;
  height: 100vh; /* ocupa toda la altura de la pantalla */
  padding: 24px;
  box-sizing: border-box;
}

.columna {
  background: #fff;
  border-radius: 14px;
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.08);
  padding: 20px;
  display: flex;
  flex-direction: column;
  overflow-y: auto; /* scroll si se pasa de la pantalla */
}

.izquierda {
  grid-column: 1;
}

.derecha {
  grid-column: 2;
}

.lista-prestamos {
  list-style: none;
  padding: 0;
  margin-top: 12px;
}

.lista-prestamos li {
  background: #f8fbff;
  margin-bottom: 8px;
  padding: 10px 14px;
  border-radius: 8px;
  box-shadow: 0 1px 5px rgba(0, 0, 0, 0.07);
  font-size: 0.95rem;
}

.equipo-lista {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(260px, 1fr));
  gap: 16px;
  margin-top: 16px;
}

.equipo-card {
  background: #f8fbff;
  padding: 14px;
  border-radius: 12px;
  box-shadow: 0 1px 6px rgba(0, 0, 0, 0.07);
  display: flex;
  justify-content: space-between;
  align-items: center;
}

</style>
