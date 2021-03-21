<template>
  <div>
    <v-container>
      <v-form>
        <v-row>
          <v-col cols="6" sm="3">
            <h1>
              Nice to meet you {{ personName }}.
            </h1>
          </v-col>
        </v-row>
      </v-form>
      <v-btn
        depressed
        @click="confirm"
        color="primary"
        class="mt-3"
      >
        Confirm
      </v-btn>
    </v-container>
  </div>
</template>

<script>
  export default {
    data: () => ({
      personName: localStorage.getItem('personName')
    }),
    methods: {
      async confirm() {
        console.log('Not yet...')
        // this.$router.push('/family')
      }
    }
  }
</script>
