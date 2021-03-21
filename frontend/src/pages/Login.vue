<template>
  <Dialogue
    title="Login"
    buttonText="Log in using web3"
    :onClick="login"
  />
</template>

<script>
  import Dialogue from '../components/Dialogue';

  export default {
    name: 'Login',
    components: {
      Dialogue
    },
    data: () => ({
    }),
    methods: {
      login() {
        console.log('login')
      }
    }
  }
</script>
