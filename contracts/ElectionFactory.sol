pragma solidity ^0.4.18;

import './ElectionECCwPrecompile.sol';


contract ElectionFactory {

    mapping(uint256 => address) public electionAddresses;

    function createNewElection(string _question, uint256 _electionID) public returns (address created) {
        require(electionAddresses[_electionID] == 0x00);

        ElectionECCwPrecompile electionContractAddress = new ElectionECCwPrecompile(_question);
        ElectionECCwPrecompile(electionContractAddress).transferOwnership(msg.sender); //TokenFactory gives away the freshly created VoucherToken ownership

        CreateNewToken(msg.sender, electionContractAddress);

        electionAddresses[_electionID] = electionContractAddress;

        return electionContractAddress;
    }

    event CreateNewToken(
        address indexed owner,
        address tokenAddress
    );
}