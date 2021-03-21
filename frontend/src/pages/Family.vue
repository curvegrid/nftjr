<template>
  <div>
    <v-container>
      <h1>The {{ familyName }} Family</h1>
      <h1>Our Artwork</h1>
    </v-container>
  </div>
</template>

<script>
  export default {
    data: () => ({
      familyName: localStorage.getItem('familyName')
    })
  }
</script>
