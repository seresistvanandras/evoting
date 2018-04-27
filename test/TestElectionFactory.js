// Specifically request an abstraction for Registry
var ElectionFactory = artifacts.require("ElectionFactory");

contract('ElectionFactory', function(accounts) {

    let electionFactoryInstance;

    it("Anyone should be able to craete a new election contract", function () {
        return ElectionFactory.deployed().then(function (instance) {
            electionFactoryInstance = instance;
            electionFactoryInstance.createNewElection("Hey! what do you want boy?", 1956);
            return electionFactoryInstance.electionAddresses.call(1956).then(function (address) {
                console.log("The created election contract address", address);
                assert.notEqual(address, "0x00", "The new election contract has not been created");
            });
        });

        //function verifyBlindSig(uint256 m, uint256 c, uint256 s)


    });
});
