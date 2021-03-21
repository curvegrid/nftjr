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
  import axios from '../../axios_with_config';

  export default {
    name: 'Login',
    components: {
      Dialogue
    },
    data: () => ({
    }),
    methods: {
      async getFamily(address) {
        const body = {
          args: [
            address,
            0, // offset
            1  // limit
          ],
          from: address
        }
        const response = await axios.post('/families/contracts/families/methods/getFamilyMemberships',body)
        const families = response.data.result.output
        if (families && families.length > 0) {
          return families[0]
        }
        return null
      },
      async login() {
        console.log('login')
        window.ethereum.request({ method: 'eth_requestAccounts' })
        this.$store.dispatch('ethers/connect')
        const addr = await ethers.getWalletAddress()
        let family
        try {
          family = await this.getFamily(addr)
        } catch(e) {
          console.log('Failed to get family', e)
        }
        if (typeof(family) !== 'undefined') {
          console.log('Found family', family)
          this.$router.push('/family')
        } else {
          console.log("Family not found, let's make one")
          this.$router.push('/first_family')
        }
      }
    }
  }
</script>
