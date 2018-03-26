let ElectionECC = artifacts.require("./ElectionECC.sol");
let ECCMultiplier = artifacts.require("./ECCMultiplier.sol");

module.exports = function(deployer) {
  deployer.deploy(ECCMultiplier).then( () => {
    deployer.deploy(ElectionECC, "what is love?");
  });
    deployer.link(ECCMultiplier, ElectionECC);
};
