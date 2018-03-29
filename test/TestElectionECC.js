// Specifically request an abstraction for Registry
var Election = artifacts.require("ElectionECC");

contract('ElectionECC', function(accounts) {

    let electionContractInstance;

    it("Organizer should be able to register eligible voters", function() {
        return Election.deployed().then(function(instance) {
            electionContractInstance = instance;
            instance.addEligibleVoter(accounts[1]);
            return instance.eligibleVoters.call(accounts[1]);
        }).then(function(member) {
            assert.equal(member[0], true, "Second account should be registered already");
        });
    });

    //function verifyBlindSig(uint256 m, uint256 c, uint256 s)

    it("Verify", function() {
        return Election.deployed().then(function(instance) {
            electionContractInstance = instance;
            electionContractInstance.verifyBlindSig("69","0x242b07d274f3edfd1ebbb4aea9d55871cf1d699e15a0c852ccf35bd50887ea4f",'0xaf7905e468c16f9e637d647a08aa0c7f1e4ae05f7426ae13b9f0fddab85ad6e6');
            return electionContractInstance.cPstorage.call(0);
        }).then(function(member) {
            console.log(new BigNumber(member).toString(16));
            //console.log(new BigNumber(member[1]).toString(16));
            //console.log(new BigNumber(member[2]).toString(16));
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
