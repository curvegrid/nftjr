import axios from 'axios';

const apiKey = 'REPLACE_WITH_MULTIBAAS_API_KEY'
const baseURL = 'http://localhost:8080/api/v0/chains/ethereum/addresses'

export default axios.create({
  baseURL: baseURL,
  headers: {
    Authorization: `Bearer ${apiKey}`
  }
})
