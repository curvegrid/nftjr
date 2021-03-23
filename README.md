# nftjr
NFT Junior

## Smart contracts setup

First, setup the appropriate environment variables:
```
cd contracts
cp .env-sample .env
```

Then edit `.env` and add the appropriate API keys and web3 private key. Then:

```
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