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
        const family = await this.getFamily(addr)
        if (family !== null) {
          this.$router.push('/family')
        } else {
          this.$router.push('/first_family')
        }
      }
    }
  }
</script>
