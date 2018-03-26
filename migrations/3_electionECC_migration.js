let ElectionECC = artifacts.require("./ElectionECC.sol");
let ECCMultiplier = artifacts.require("./ECCMultiplier.sol");

module.exports = function(deployer) {
    deployer.link(ECCMultiplier, ElectionECC);

};