<template>
  <div>
    <v-container>
      <v-form>
        <v-row>
          <v-col cols="6" sm="3">
            <h1>
              My family is the
            </h1>
                <v-text-field
                  v-model="familyName"
                  outlined
                  style="font-size: 2em;"
                >
                <div slot="append">family.</div>
                </v-text-field>
          </v-col>
          </v-row>
          <v-row>
            <v-col cols="3" sm="3">
              <h1>
                And you can call me
              </h1>
              <v-text-field
                v-model="personName"
                outlined
                style="font-size: 2em;"
              >
              </v-text-field>
            </v-col>
          </v-row>
        </v-form>
      <v-btn
        depressed
        @click="next"
        color="primary"
      >
        Confirm
      </v-btn>
    </v-container>
  </div>
</template>

<script>
  export default {
    data: () => ({
      familyName: localStorage.getItem('familyName') || '',
      personName: localStorage.getItem('personName') || ''
    }),
    methods: {
      async next() {
        localStorage.setItem('familyName',this.familyName)
        localStorage.setItem('personName',this.personName)
        this.$router.push('/avatar')
      }
    }
  }
</script>
