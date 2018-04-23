pragma solidity ^0.4.18;

import 'zeppelin-solidity/contracts/ownership/Ownable.sol';
import {ECCMath} from "crypto/ECCMath.sol";
import {Secp256k1} from "crypto/Secp256k1.sol";
import {eccPrecompiles} from './utils/preCompiles.sol';

contract Election is Ownable  {
  mapping (address => Voter) public eligibleVoters;
  mapping (uint256 => address) public blindedVotes;
  mapping (uint256 => uint256) public votes; //counts the votes for specific options

  string public question;

  //prime1 11
  //prime2 5
  uint256 public publicModulo = 55;

  //privKey: 23
  uint256 public publicExponent = 7;


  uint256 public blindlySignedSig;
  uint256 public verifiedSig;

  struct Voter {
    bool eligible;
    uint256 blindedVote;
    uint256 signedBlindedVote;
  }

  event RequestToBlindlySign(address indexed voter);
  event voteSuccess(address indexed voter, uint256 hashOfVote);
  event debug(uint256 vote, uint256 votehash);

  //constructor
  function Election (string _question) public {
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


//uint(keccak256(uint(1))): 80084422859880547211683076133703299733277748156566366325829078699459944778998
//keccak256(uint(1)): 0xb10e2d527612073b26eecdfd717e6a320cf44b4afac2b0732d9fcbe2b7fa0cf6
//blindlySignedShit: 22249075885109206276024811279364626717013279169439911258
  function Vote(uint256 choiceCode, uint256 vote, uint256 hashVote, uint256 blindlySignedVote) public {
    verifyBlindSig(hashVote, blindlySignedVote);
    debug(uint(keccak256(uint(vote))),hashVote);
    require(uint(keccak256(uint(vote))) == hashVote);
    votes[choiceCode]++;

    voteSuccess(msg.sender,hashVote);
  }

  function addEligibleVoter(address _voter) onlyOwner public {
    eligibleVoters[_voter].eligible = true;
  }

  function removeEligibleVoter(address _voter) onlyOwner public {
    eligibleVoters[_voter].eligible = false;
  }
  function verifyBlindSig(uint256 vote,uint256 blindlySignedVote) public returns (bool){
    require(eccPrecompiles.expmod(blindlySignedVote,publicExponent,publicModulo) == (vote % publicModulo));
  }

  function generatingSigs() public {
   blindlySignedSig = ECCMath.expmod(uint(keccak256(uint(1))),23,publicModulo);
   verifiedSig = ECCMath.expmod(blindlySignedSig,publicExponent,publicModulo);
  }
}
