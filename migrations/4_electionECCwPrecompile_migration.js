var Election = artifacts.require("./ElectionECCwPrecompile.sol");

module.exports = function(deployer) {
  deployer.deploy(Election, "what do you want?");
};
