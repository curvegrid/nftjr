const Market = artifacts.require("Market");
const Media = artifacts.require("Media");
const Families = artifacts.require("Families");

const { Deployer } = require("truffle-multibaas-plugin");

module.exports = async function (_deployer, network) {
  const deployer = new Deployer(_deployer, network);
  await deployer.setup();

  // deploy and configure the contracts
  const [, marketAddress, marketContract] = await deployer.deployWithOptions({
    contractLabel: "market",
    contractVersion: "1.0",
    addressLabel: "market",
  }, Market);

  const [, familiesAddress, familiesContract] = await deployer.deployWithOptions({
    contractLabel: "families",
    contractVersion: "1.0",
    addressLabel: "families",
  }, Families);

  const [, mediaAddress, mediaContract] = await deployer.deployWithOptions({
    contractLabel: "media",
    contractVersion: "1.0",
    addressLabel: "media",
  }, Media, marketAddress.address, familiesAddress.address);

  await marketContract.configure(mediaAddress.address);

  // setup a family
  await familiesContract.startFirstFamily("Smith", "Dad", "👨");
};
