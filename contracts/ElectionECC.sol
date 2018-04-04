pragma solidity ^0.4.18;

import 'zeppelin-solidity/contracts/ownership/Ownable.sol';
import {ECCMath} from "./ECCMath.sol";
import {Secp256k1} from "./Secp256k1.sol";
import {ECCMultiplier} from "./ECCMultiplier.sol";

contract ElectionECC is Ownable  {
  mapping (address => Voter) public eligibleVoters;
  mapping (uint256 => address) public blindedVotes;
  mapping (uint256 => uint256) public votes; //counts the votes for specific options

  string public question;

  uint constant n = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141;
  uint constant p = 0xfffffffffffffffffffffffffffffffffffffffffffffffffffffffefffffc2f;

  // Base point (generator) G

  //secp256k1 generator point
  uint256[3] public generatorPoint; //in affine coordinates
  uint256[3] public pubKeyOfOrganizer; //in affine coordinates

  uint[3] public cPstorage;
  uint[3] public sGstorage;
  uint[3] public sumStorage;
  uint[3] public affinSumStorage;

  struct Voter {
    bool eligible;
    uint256 blindedVote;
    uint256 signedBlindedVote;
  }

  event RequestToBlindlySign(address indexed voter);
  event voteSuccess(address indexed voter, uint hashOfVote);

  //constructor
  function ElectionECC (string _question) public {
    question = _question;
    generatorPoint[0] = 0x79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798;
    generatorPoint[1] = 0x483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8;
    generatorPoint[2] = 1;
    pubKeyOfOrganizer[0] = 0xd0988bfa799f7d7ef9ab3de97ef481cd0f75d2367ad456607647edde665d6f6f;
    pubKeyOfOrganizer[1] = 0xbdd594388756a7beaf73b4822bc22d36e9bda7db82df2b8b623673eefc0b7495;
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


  function Vote(uint256 choiceCode, uint256 vote, uint hashVote, uint256 c, uint256 s) public {
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

  function uintToString(uint v) constant returns (string str) {
    uint maxlength = 78;
    bytes memory reversed = new bytes(maxlength);
    uint i = 0;
    while (v != 0) {
      uint remainder = v % 10;
      v = v / 10;
      reversed[i++] = byte(48 + remainder);
    }
    bytes memory s = new bytes(i);
    for (uint j = 0; j < i; j++) {
      s[j] = reversed[i - 1 - j];
    }
    str = string(s);
  }

  //The core of the contract: onchain ECC BlindSig verification
  function verifyBlindSig(uint256 m, uint256 c, uint256 s) public {

    uint[3] memory cP = ECCMultiplier.multiply(c,pubKeyOfOrganizer);
    uint[3] memory sG = ECCMultiplier.multiply(s, generatorPoint);
    uint[3] memory sum = Secp256k1._add(cP, sG); //need to convert the x coordinate to affine coordinate from Jacobian coordinate before projecting the x coordinate
    uint[3] memory affineSum = ECCMath.toZ12(sum,p);

    uint projection = affineSum[0] % n;

    cPstorage = cP;
    sGstorage = sG;
    sumStorage = sum;
    affinSumStorage = affineSum;

    require(c == uint(keccak256(uintToString(m),uintToString(projection))));
  }


}
