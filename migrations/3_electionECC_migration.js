var ElectionECC = artifacts.require("./ElectionECC.sol");

module.exports = function(deployer) {
  deployer.deploy(ElectionECC, "what do you want? ECC");
};
