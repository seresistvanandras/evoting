pragma solidity ^0.4.19;

import 'zeppelin-solidity/contracts/ownership/Ownable.sol';
import 'zeppelin-solidity/contracts/math/SafeMath.sol';
import {eccPrecompiles} from './utils/preCompiles.sol';

contract ElectionECCwCommitReveal is Ownable {
  using SafeMath for uint256;
  mapping (address => Voter) public eligibleVoters;
  mapping (uint256 => address) public blindedVotes;
  mapping (uint256 => uint256) public votes; //counts the votes for specific options
  mapping (uint256 => bool) public usedSignatures;
  mapping (address => uint256) public commitments;

  string public question;

  //https://github.com/ethereum/EIPs/pull/213

  //Y^2 = X^3 + 3
  uint constant p = 0x30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd47; //field modulus

  uint constant n = 0x30644e72e131a029b85045b68181585d2833e84879b9709143e1f593f0000001; //curve order

  uint256[2] public generatorPoint; //in affine coordinates
  uint256[2] public pubKeyOfOrganizer; //in affine coordinates

  uint256 public endOfCommit;
  uint256 public endOfReveal;

  struct Voter {
    bool eligible;
    uint256 blindedVote;
    uint256 signedBlindedVote;
  }

  event RequestToBlindlySign(address indexed voter);
  event voteSuccess(address indexed voter, uint256 choiceCode);


  //constructor
  function ElectionECCwCommitReveal (string _question, uint256 _endOfCommit, uint256 _endOfReveal) public {
    question = _question;

    endOfCommit = _endOfCommit;
    endOfReveal = _endOfReveal;

    //altbn128 generator point
    generatorPoint[0] = 1;
    generatorPoint[1] = 2;
    pubKeyOfOrganizer[0] = 0x1a619cedd96d8ecda3e1a09a577dc3f04422fa54a79b3a53ca5a077fe8b3dbf8;
    pubKeyOfOrganizer[1] = 0x24f4f2f8f95269d63d7cb286934796d9e69ef2b6907d78e8d6ddc6e76cdd748d;
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

  function commit(uint256 _commitment) public {
    require(block.timestamp < endOfCommit);
    commitments[msg.sender] = _commitment;
  }

  function reveal(uint256 _choiceCode, uint256 _nonce, uint256 c, uint256 s) public {
    require(block.timestamp < endOfReveal);
    require(commitments[msg.sender] == uint(keccak256(uintToString(_choiceCode), uintToString(_nonce))));
    Vote(_choiceCode, c, s);
  }

  function Vote(uint256 choiceCode, uint256 c, uint256 s) internal {
    require(!usedSignatures[c]);
    usedSignatures[c] = true;
    verifyBlindSig(choiceCode, c, s);
    votes[choiceCode].add(1);

    voteSuccess(msg.sender,choiceCode);
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
    uint[2] memory cP = eccPrecompiles.ecmul(pubKeyOfOrganizer[0], pubKeyOfOrganizer[1], c);
    uint[2] memory sG = eccPrecompiles.ecmul(generatorPoint[0], generatorPoint[1], s);

    uint[2] memory sum = eccPrecompiles.ecadd(cP[0], cP[1], sG[0], sG[1]);

    uint projection = sum[0] % n;

    require(c == uint(keccak256(uintToString(m),uintToString(projection))));
  }
  
}
