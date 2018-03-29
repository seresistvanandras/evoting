let ElectionECC = artifacts.require("./ElectionECC.sol");
let ECCMultiplier = artifacts.require("./ECCMultiplier.sol");
let Secp256k1 = artifacts.require("./Secp256k1.sol");
let ECCMath = artifacts.require("./ECCMath.sol");

module.exports = function(deployer) {
  deployer.deploy(ECCMath);
  deployer.deploy(ECCMultiplier);
  deployer.deploy(Secp256k1);

  deployer.link(ECCMath, ElectionECC);
  deployer.link(ECCMultiplier, ElectionECC);
  deployer.link(Secp256k1, ElectionECC);

  deployer.deploy(ElectionECC, "what is love?");
};
