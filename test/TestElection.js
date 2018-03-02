// Specifically request an abstraction for Registry
var Election = artifacts.require("Election");

contract('Election', function(accounts) {
  it("Organizer should be able to register eligible voters", function() {
    return Election.deployed().then(function(instance) {
      instance.addEligibleVoter(accounts[1]);
      return instance.eligibleVoters.call(accounts[1]);
    }).then(function(member) {
      assert.equal(member[0], true, "Second account should be registered already");
    });
  });
});
