pragma solidity ^0.4.18;

import 'zeppelin-solidity/contracts/ownership/Ownable.sol';
import {ECCMath} from "crypto/ECCMath.sol";
import {Secp256k1} from "crypto/Secp256k1.sol";
import {ECCMultiplier} from "./ECCMultiplier.sol";

contract ElectionECC is Ownable  {
  mapping (address => Voter) public eligibleVoters;
  mapping (uint256 => address) public blindedVotes;
  mapping (uint256 => uint256) public votes; //counts the votes for specific options

  string public question;

  uint constant n = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141;

  // Base point (generator) G

  //secp256k1 generator point
  uint256[3] public generatorPoint; //in affine coordinates
  uint256[3] public pubKeyOfOrganizer; //in affine coordinates

  struct Voter {
    bool eligible;
    uint256 blindedVote;
    uint256 signedBlindedVote;
  }

  event RequestToBlindlySign(address indexed voter);
  event voteSuccess(address indexed voter, uint256 hashOfVote);
  event debug(uint256 vote, uint256 votehash);

  //constructor
  function ElectionECC (string _question) public {
    question = _question;
    generatorPoint[0] = 0x79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798;
    generatorPoint[1] = 0x483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8;
    generatorPoint[2] = 1;
    pubKeyOfOrganizer[0] = 0x5982504b6c641ab4256ac941b6d645108ebab172b797a5d2f82c5905c4cb00c1;
    pubKeyOfOrganizer[1] = 0x4995ad44d9a907c13100a9542f93c717019d97e09d51585d3fba54efaf74366d;
    pubKeyOfOrganizer[2] = 1;
  }

  //blinded message should be recorded in order to be able to verify that Organizer provided a correct signature on the blinded msg
  function requestBlindSig(uint256 blindedVote) public {
    require(eligibleVoters[msg.sender].eligible);
    blindedVotes[blindedVote] = msg.sender;
    RequestToBlindlySign(msg.sender);

  }

  //requested blindSig is recorded on the blockchain for auditing purposes
  function writeBlindSig(address _voter, uint256 blindSig) onlyOwner public {
    eligibleVoters[_voter].signedBlindedVote = blindSig;
    eligibleVoters[_voter].eligible = false;
  }


//uint(keccak256(uint(1))): 80084422859880547211683076133703299733277748156566366325829078699459944778998
//keccak256(uint(1)): 0xb10e2d527612073b26eecdfd717e6a320cf44b4afac2b0732d9fcbe2b7fa0cf6
//blindlySignedShit: 22249075885109206276024811279364626717013279169439911258
  function Vote(uint256 choiceCode, uint256 vote, uint256 hashVote, uint256 c, uint256 s) public {
    verifyBlindSig(hashVote, c, s);
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

  //The core of the contract: onchain ECC BlindSig verification
  function verifyBlindSig(uint256 m, uint256 c, uint256 s) public returns (bool){
    uint[3] memory cP = ECCMultiplier.multiply(c,pubKeyOfOrganizer);
    uint[3] memory sG = ECCMultiplier.multiply(s, generatorPoint);

    uint[3] memory sum = Secp256k1._add(cP, sG); //maybe need to convert the x coordinate to affine coordinate from Jacobian coordinate before projecting the x coordinate
    uint projection = sum[0] % n;
    require(c == uint(keccak256(m,projection)));
  }

}
