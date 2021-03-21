# nftjr
NFT Junior

## Smart contracts setup

```
cd contracts
yarn install
truffle migrate --reset
```
## Frontend Setup

```
cd frontend
```
- Copy `./axios_with_config.template.js` to `./axios_with_config.js`
- In `axios_with_config.js`
  - Update the `apiKey` variable with a valid MultiBaas API key
  - Update the `baseURL` variable with the correct hostname
```
yarn install
yarn serve
```
- Configure CORS in MultiBaas > Admin > CORS Domains to include the domain and port of server