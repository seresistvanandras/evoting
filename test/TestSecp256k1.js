// Specifically request an abstraction for Registry
var Secp256k1 = artifacts.require("Secp256k1");
var BigNumber = require('bignumber.js');

contract('Secp256k1', function(accounts) {

    let ContractInstance;

    it("Doubling", function() {
        return Secp256k1.deployed().then(function(instance) {
            ContractInstance = instance;
            return ContractInstance._double(['0x79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798','0x483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8',1]);
        }).then(function(member) {
            console.log(new BigNumber(member[0]).toString(16));
            console.log(new BigNumber(member[1]).toString(16));
            console.log(new BigNumber(member[2]).toString(16));
        });
    });

    it("Adding", function() {
        return Secp256k1.deployed().then(function(instance) {
            ContractInstance = instance;
            return ContractInstance._add(['0x79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798','0x483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8',1],['0x79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798','0x483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8',1]);
        }).then(function(member) {
            console.log(new BigNumber(member[0]).toString(16));
            console.log(new BigNumber(member[1]).toString(16));
            console.log(new BigNumber(member[2]).toString(16));
        });
    });


    /*
        it("Organizer should be able to remove eligible voters", function() {
            return Election.deployed().then(function(instance) {
                electionContractInstance.addEligibleVoter(accounts[1]);
                return electionContractInstance.eligibleVoters.call(accounts[1]);
            }).then(function(member) {
                assert.equal(member[0], true, "Second account should be registered already");
                electionContractInstance.removeEligibleVoter(accounts[1]);
                return electionContractInstance.eligibleVoters.call(accounts[1]);
            }).then(function(member) {
                assert.equal(member[0], false, "Second account should have been removed!")
            });
        });

        it("Voters should be able to vote", function() {
            return Election.deployed().then(function(instance) {
                electionContractInstance.addEligibleVoter(accounts[0]);
                electionContractInstance.Vote(1,1,"80084422859880547211683076133703299733277748156566366325829078699459944778998",12);
                return electionContractInstance.votes.call(1);
            }).then(function(member) {
                assert.equal(member.toNumber(), 1, "Vote has been cast");
            });
        });

        it("Votesuccess event should be emitted", function() {
            return Election.deployed().then(function(instance) {
                electionContractInstance.addEligibleVoter(accounts[0]);
                return electionContractInstance.Vote(1,1,"80084422859880547211683076133703299733277748156566366325829078699459944778998",12);
            }).then(function(member) {
                assert.equal(member.logs[1].args.voter,accounts[0], 'The event is emitted');
            });
        });

        it("Voters should be only able to cast a valid vote", function() {
            return Election.deployed().then(function(instance) {
                electionContractInstance.addEligibleVoter(accounts[0]);
                return electionContractInstance.Vote(1);
            }).then(() => {
                assert.ok(false, "It didn't fail");
        }, () => {
                assert.ok(true, "Passed");
            });
        });
    */



});
