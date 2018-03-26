var Migrations = artifacts.require("./Migrations.sol");
var ElectionECC = artifacts.require("./ElectionECC.sol");

module.exports = function(deployer) {
  deployer.deploy(Migrations);
  deployer.deploy(ElectionECC,"What is da question?");
};

