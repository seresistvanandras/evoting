pragma solidity ^0.4.18;

import 'zeppelin-solidity/contracts/ownership/Ownable.sol';
import {ECCMath} from "crypto/ECCMath.sol";

contract Election is Ownable  {
  mapping (address => Voter) public eligibleVoters;
  mapping (uint256 => address) public blindedVotes;
  mapping (uint256 => uint256) public votes; //counts the votes for specific options

  string public question;

  //96-bit random prime numbers
  //prime1 52632226726678600070752309183
  //prime2 4692554808980366270917812557
  uint256 public publicModulo = 246979608633620626478852615866591005359742015214903810931;
  //totient of the modulo 246979608633620626478852615809266223824083048873233689192
  //privKey: 208099455097861223341963187893673510834579946576437192993
  uint256 public publicExponent = 65537;

  struct Voter {
    bool eligible;
    uint256 blindedVote;
    uint256 signedBlindedVote;
  }

  event RequestToBlindlySign(address indexed voter);
    event voteSuccess(address indexed voter, uint256 hashOfVote);

  //constructor
  function Election (string _question, uint256 _publicModulo, uint256 _publicExponent) public {
    question = _question;
    //publicModulo = _publicModulo;
    //publicExponent = _publicExponent;
  }


  function requestBlindSig(uint256 blindedVote) public {
    require(eligibleVoters[msg.sender].eligible);
    blindedVotes[blindedVote] = msg.sender;
    RequestToBlindlySign(msg.sender);
    eligibleVoters[msg.sender].eligible = false;
  }

  function writeBlindSig(address _voter, uint256 blindSig) onlyOwner public {
    eligibleVoters[_voter].signedBlindedVote = blindSig;
  }

  function Vote(uint256 choiceCode, uint256 vote, uint256 hashVote, uint256 blindlySignedVote) public {
    verifyBlindSig(hashVote, blindlySignedVote);
    require(sha3(vote)==bytes32(hashVote));
    votes[choiceCode]++;

    voteSuccess(msg.sender, hashVote);

  }

  function addEligibleVoter(address _voter) onlyOwner public {
    eligibleVoters[_voter].eligible = true;
  }

  function removeEligibleVoter(address _voter) onlyOwner public {
    eligibleVoters[_voter].eligible = false;
  }
  function verifyBlindSig(uint256 vote,uint256 blindlySignedVote) public returns (bool){
    require(ECCMath.expmod(blindlySignedVote,publicExponent,publicModulo) == vote);
  }


















}
