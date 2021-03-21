<template>
  <v-card
    class="rounded-xl mx-auto my-12 accent pa-6"
    elevation="0"
    max-width=374
    align="center"
    dark
  >
    <v-card-title
      class="justify-center"
    >
      <h1>
          {{ title }}
      </h1>
    </v-card-title>
    <v-btn
      depressed
      class="ma-6"
      @click="onClick"
      color="primary"
    >
      {{ buttonText }}
    </v-btn>
  </v-card>
</template>

<script>
  export default {
    name: 'Login',
    props: {
        title: {
            type: String,
            required: true
        },
        buttonText: {
            type: String,
            required: true
        },
        onClick: {
            type: Function,
            required: true
        }
    },
    data: () => ({
    }),
  }
</script>