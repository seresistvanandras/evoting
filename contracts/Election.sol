pragma solidity ^0.4.18;

import 'zeppelin-solidity/contracts/ownership/Ownable.sol';

contract Election is Ownable  {
  mapping (address => Voter) public eligibleVoters;
  mapping (uint256 => address) public blindedVotes;
  mapping (uint256 => uint256) public votes; //counts the votes for specific options

  string public question;

  uint256 public publicModulo;
  uint256 public publicExponent;

  struct Voter {
    bool eligible;
    uint256 blindedVote;
    uint256 signedBlindedVote;
  }

  event RequestToBlindlySign(address indexed voter);

  //constructor
  function Election (string _question, uint256 _publicModulo, uint256 _publicExponent) public {
    question = _question;
    publicModulo = _publicModulo;
    publicExponent = _publicExponent;
  }


  function requestBlindSig(uint256 blindedVote) public {
    require(eligibleVoters[msg.sender].eligible);
    blindedVotes[blindedVote] = msg.sender;
    RequestToBlindlySign(voter);
    eligibleVoters[msg.sender].eligible = false; 
  }

  function writeBlindSig(address _voter, uint256 blindSig) onlyOwner public {
    eligibleVoters[_voter].signedBlindedVote = blindSig;
  }

  function Vote(uint256 vote, uint256 blindlySignedVote) public {
    require(verifyBlindSig(blindlySignedVote));
    votes[vote]++;
  }

  function addEligibleVoter(address _voter) onlyOwner public {
    eligibleVoters[_voter].eligible = true;
  }

  function removeEligibleVoter(address _voter) onlyOwner public {
    eligibleVoters[_voter].eligible = false;
  }
  //TODO should verify the sig against the given pubKey
  function verifyBlindSig(uint256 blindlySignedVote) public returns (bool){
//alá lett-e írva a publikus mod cuccosokkal
  }
}
