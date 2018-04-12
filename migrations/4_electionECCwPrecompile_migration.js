var Election = artifacts.require("./ElectionECCwPrecompile.sol");

module.exports = function(deployer) {
  deployer.deploy(Election, "How do you like STARTUP SAFARY BUDAPEST 2018?");
};
