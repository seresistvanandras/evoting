var Factory = artifacts.require("./ElectionFactory.sol");
var preCompiles = artifacts.require("./eccPrecompiles.sol");

module.exports = function(deployer) {
    deployer.deploy(preCompiles);

    deployer.link(preCompiles, Factory);
    deployer.deploy(Factory);
};