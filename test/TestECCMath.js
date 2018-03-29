// Specifically request an abstraction for Registry
var ECCMath = artifacts.require("ECCMath");
var BigNumber = require('bignumber.js');

contract('ECCMath', function(accounts) {

    let ContractInstance;

    it("Conversion to Affine", function() {
        return ECCMath.deployed().then(function(instance) {
            ContractInstance = instance;

            let prime = '0xfffffffffffffffffffffffffffffffffffffffffffffffffffffffefffffc2f';
            /*let zInv;
            let z2Inv;

            return ContractInstance.invmod('0x9075b4ee4d4788cabb49f7f81c221151fa2f68914d0aa833388fa11ff621a970',prime).then(function(returnedzInv) {
              zInv = returnedzInv.toString(16);
              return ContractInstance.invmod('0x219b5a96ad06acb1af315f334dcd7697c5be0295239788291393a6e146309f99',prime).then(function(returnedZ2Inv) {
                  z2Inv = returnedZ2Inv.toString(16);
*/

/*                  return ContractInstance.toZ12(['0x7d152c041ea8e1dc2191843d1fa9db55b68f88fef695e2c791d40444b365afc2',
                      '0x56915849f52cc8f76f5fd7e4bf60db4a43bf633e1b1383f85fe89164bfadcbdb',
                      '0x9075b4ee4d4788cabb49f7f81c221151fa2f68914d0aa833388fa11ff621a970'
                      ],prime);
*/
return ContractInstance.invMod('0x','0x')
              }).then(function(member) {
                  console.log(new BigNumber(member[0]).toString(16));
                  console.log(new BigNumber(member[1]).toString(16));
                  console.log(new BigNumber(member[2]).toString(16));
              });

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




