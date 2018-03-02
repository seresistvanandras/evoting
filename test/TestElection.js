// Specifically request an abstraction for Registry
var Election = artifacts.require("Election");

contract('Election', function(accounts) {

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




});
