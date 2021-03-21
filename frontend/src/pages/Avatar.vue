<template>
  <div>
    <v-container>
      <v-form>
        <v-row>
          <v-col cols="7" sm="3">
            <h1>
              Nice to meet you {{ personName }}.
            </h1>
          </v-col>
        </v-row>
        <v-row>
          <v-col cols="7" sm="3">
            <h1>
              Please select an avatar to use.
            </h1>
          </v-col>
        </v-row>
        <v-row>
          <v-col cols="7" sm="3">
            <h1>
              You can change this later.
            </h1>
          </v-col>
        </v-row>
        <v-row>
          <v-col
            cols="1"
          >
            <v-select
              v-model="avatar"
              :items="emoji"
              label="Avatar"
            ></v-select>
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
  import emoji from './emoji'
  import axios from '../../axios_with_config'
  import ethers from '../store/ethers/ethersConnect';

  export default {
    data: () => ({
      avatar: localStorage.getItem('avatar') || '',
      personName: localStorage.getItem('personName'),
      familyName: localStorage.getItem('familyName'),
      emoji: emoji
    }),
    methods: {
      async startFirstFamily() {
        const addr = await ethers.getWalletAddress()
        const body = {
          args: [
            this.familyName,
            this.personName,
            this.avatar
          ],
          from: addr
        }
        const response = await axios.post('/families/contracts/families/methods/startFirstFamily',body)
        return response.data.result.output
      },
      async startFamily() {
        const addr = await ethers.getWalletAddress()
        const body = {
          args: [
            this.familyName
          ],
          from: addr
        }
        const response = await axios.post('/families/contracts/families/methods/startFamily',body)
        return response.data.result.tx
      },
      async confirm() {
        localStorage.setItem('avatar',this.avatar)
        const wallet = await ethers.getWallet()
        var tx
        try {
          tx = await this.startFirstFamily()
        } catch (e) {
          try {
            tx = await this.startFamily()
          } catch (e2) {
            console.warn('Failed to start a family', e, e2)
          }
        }
        const ethersTx = ethers.formatEthersTx(tx)
        await wallet.sendTransaction(ethersTx)
        this.$router.push('/family')
      }
    }
  }
</script>
