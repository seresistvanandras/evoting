let ElectionECC = artifacts.require("./ElectionECC.sol");
let ECCMultiplier = artifacts.require("./ECCMultiplier.sol");

module.exports = function(deployer) {
  deployer.deploy(ECCMultiplier);
  deployer.link(ECCMultiplier, ElectionECC);
  deployer.deploy(ElectionECC, "what is love?");
};
