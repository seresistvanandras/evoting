var Election = artifacts.require("./Election.sol");
var preCompiles = artifacts.require("./eccPrecompiles.sol");

module.exports = function(deployer) {
    deployer.deploy(preCompiles);

    deployer.link(preCompiles, Election);
    deployer.deploy(Election, "what do you want?");
};
