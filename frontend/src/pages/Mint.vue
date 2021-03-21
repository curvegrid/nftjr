<template>
  <v-container fluid>
    <v-row align="center">
      <!-- <v-col cols="6">
        <v-btn
          depressed
          class="ma-6"
          @click="init"
          color="primary"
        >
          Init
        </v-btn> 
      </v-col>-->
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
        :src="imageURI"
        max-height="250"
        max-width="250"
      ></v-img>
    </v-row>
    <v-row align="center">
      <v-col cols="6">
        <p>Title</p>
        <v-text-field
          v-model="title"
        ></v-text-field>
      </v-col>
    </v-row>
    <v-row align="center">
      <v-col cols="6">
        <p>Description</p>
        <v-textarea
          v-model="description"
        ></v-textarea>
      </v-col>
    </v-row>
    <v-row align="center">
      <v-btn
          depressed
          class="ma-6"
          @click="mint"
          color="primary"
        >
          Mint
        </v-btn>
    </v-row>
  </v-container>
</template>

<script>
  import ethers from '../store/ethers/ethersConnect';
  import axios from '../../axios_with_config';
  import axiosNFT from 'axios';
  import sha256 from 'js-sha256';

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
      imageURI: '',
      title: '',
      description: ''
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
            this.imageURI = 'https://cloudflare-ipfs.com/ipfs/'+cid+'/'+filename
          }
        )
      },
      async storeMetadata(metadata) {
        const URL = 'http://localhost:8090/upload';
        let config = {
          header : {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          }
        }

        const response = await axiosNFT.post(
          URL, 
          metadata,
          config
        );

        return response;
      },
      async mint() {
        // compose the metadata
        const metadata = {
          description: this.description,
          mimeType: "image/png",
          name: this.title,
          version: "zora-20210101"
        }

        console.log(metadata)

        // store the metadata
        const metadataResponse = await this.storeMetadata(metadata)
        const metadataURI = 'https://cloudflare-ipfs.com/ipfs/'+metadataResponse.data.value.cid
        console.log(metadataURI)

        // mint the NFT!
        const media = [
          this.imageURI,
          metadataURI,
          '0x'+sha256(JSON.stringify(metadata)),
          '0x'+sha256(JSON.stringify(metadata)+"metadata"),
          this.family.id
        ];
        console.log(media)
        const bidShares = [[0],[0],[100000000000000000000]]
        const body = {
          args: [
            media,
            bidShares
          ],
          "from": this.mintFor
        }
        const mintResponse = await axios.post('/zora_media/contracts/zora_media/methods/mint',body)
        console.log(mintResponse)

        const wallet = await ethers.getWallet()
        const tx = mintResponse.data.result.tx;
        const ethersTx = ethers.formatEthersTx(tx)
        await wallet.sendTransaction(ethersTx)
      }
    }
  }
</script>
