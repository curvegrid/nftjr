<template>
  <Dialogue
    title="Login"
    buttonText="Log in using web3"
    :onClick="login"
  />
</template>

<script>
  import Dialogue from '../components/Dialogue';
  import ethers from '../store/ethers/ethersConnect';

  export default {
    name: 'Login',
    components: {
      Dialogue
    },
    data: () => ({
    }),
    methods: {
      async login() {
        console.log('login')
        window.ethereum.request({ method: 'eth_requestAccounts' })
        this.$store.dispatch('ethers/connect')
        const addr = await ethers.getWalletAddress()
        console.log(addr);
      }
    }
  }
</script>
