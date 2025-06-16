<template>
  <div>
    <h2>Ingreso Administrador</h2>
    <form @submit.prevent="login">
      <input v-model="usuario" placeholder="Usuario" required />
      <input v-model="password" type="password" placeholder="Contraseña" required />
      <button type="submit">Ingresar</button>
      <div v-if="error" style="color: red">{{ error }}</div>
    </form>
  </div>
</template>

<script setup>
import { ref } from 'vue'

const usuario = ref('')
const password = ref('')
const error = ref('')

// Simulado, después conectá con la API real de login de admin
const login = () => {
  if (usuario.value === 'admin' && password.value === 'admin') {
    $emit('login-success')
  } else {
    error.value = 'Usuario o contraseña incorrectos'
  }
}
</script>
