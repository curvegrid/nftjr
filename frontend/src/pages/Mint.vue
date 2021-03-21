<template>
  <v-container fluid>
    <v-row align="center">
      <v-col cols="6">
        <v-btn
          depressed
          class="ma-6"
          @click="init"
          color="primary"
        >
          Init
        </v-btn> 
      </v-col>
    </v-row>
    <v-row align="center">
      <v-col cols="4">
        <h1>
          Submit a new artwork for
        </h1>
      </v-col>
      <v-col cols="3">
        <v-autocomplete
          v-model="mintFor"
          :items="familyMembers"
          item-value="account"
          item-text="name"
        ></v-autocomplete>
      </v-col>
    </v-row>
    <v-row align="center">
      <v-col cols="6">
        <input type="file" accept="image/*" @change="uploadImage($event)" id="file-input">
      </v-col>
    </v-row>
    <v-row align="center">
      <v-img 
        :src="image"
        max-height="250"
        max-width="250"
      ></v-img>
    </v-row>
  </v-container>
</template>

<script>
  import ethers from '../store/ethers/ethersConnect';
  import axios from '../../axios_with_config';
  import axiosNFT from 'axios';

  export default {
    name: 'Mint',
    data: () => ({
      family: {
        id: 0,
        name: ''
      },
      account: '',
      familyMembers: [],
      mintFor: '',
      image: ''
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
      },
      uploadImage(event) {
        // const URL = 'https://nft.storage/api/upload';
        const URL = 'http://localhost:8090/upload';

        let data = new FormData();
        data.append('file', event.target.files[0]);

        let config = {
          header : {
            'Accept': 'application/json',
          }
        }

        axiosNFT.post(
          URL, 
          data,
          config
        ).then(
          response => {
            const cid = response.data.value.cid
            const filename = response.data.value.files[0].name
            console.log('image upload response > ', cid)
            this.image = 'https://cloudflare-ipfs.com/ipfs/'+cid+'/'+filename
          }
        )
      }
    }
  }
</script>
