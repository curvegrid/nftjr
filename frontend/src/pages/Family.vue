<template>
  <div>
    <v-container>
      <h1>The {{ familyName }} Family</h1>

      <h1>Our Artwork</h1>
    </v-container>
  </div>
</template>

<script>
  import ethers from '../store/ethers/ethersConnect';
  import axios from '../../axios_with_config';

  export default {
    name: 'Family',
    data: () => ({
      family: {
        id: null,
        name: ''
      },
      familyMembers: [],
      familyName: localStorage.getItem('familyName')
    }),
    mounted: function() {
      this.$nextTick(function () {
        setTimeout(this.init, 2000)
      })
    },
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
      async getFamilyMembers(id) {
        const body = {
          args: [
            id,
            0, // offset
            10  // limit
          ]
        }
        const response = await axios.post('/families/contracts/families/methods/getFamilyMembers',body)
        const families = response.data.result.output
        if (families && families.length > 0) {
          return families
        }
        return []
      },
      async init() {
        // get wallet address
        window.ethereum.request({ method: 'eth_requestAccounts' })
        this.$store.dispatch('ethers/connect')
        const addr = await ethers.getWalletAddress()
        this.account = addr

        // get family
        const family = await this.getFamily(addr)
        if (family !== null) {
          this.family.id = family.id
          this.family.name = family.name
          // console.log(this.family.name)
        } else {
          console.log('unable to retrieve family')
        }

        // get family members
        const familyMembers = await this.getFamilyMembers(family.id)
        // console.log(familyMembers)
        this.familyMembers = familyMembers
      }
    }
  }
</script>
