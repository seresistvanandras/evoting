pragma solidity ^0.4.24;


import 'zeppelin-solidity/contracts/ownership/Ownable.sol';
import 'zeppelin-solidity/contracts/math/SafeMath.sol';

//https://github.com/ethereum/EIPs/pull/213 -> altbn128 precompiles
import {eccPrecompiles} from './utils/preCompiles.sol';

contract ElectionECCwPrecompile is Ownable {

  using SafeMath for uint256;

  mapping (address => Voter) public eligibleVoters;  // array of eligible voters
  mapping (uint256 => address) public blindedVotes;  // array of blinded votes
  mapping (uint256 => uint256) public votes; // counts the votes for specific options
  mapping (uint256 => bool) public usedSignatures;  // array of used signatures

  event RequestToBlindlySign(address indexed voter);
  event voteSuccess(address indexed voter, uint256 choiceCode);

  string public question;

  uint constant p = 0x30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd47; // field modulus
  uint constant n = 0x30644e72e131a029b85045b68181585d2833e84879b9709143e1f593f0000001; // curve order

  // altbn128 generator point
  uint256[2] public generatorPoint; // in affine coordinates
  uint256[2] public pubKeyOfOrganizer; // in affine coordinates

  // structure that stores voter data
  struct Voter {
    bool eligible;
    uint256 blindedVote;
    uint256 signedBlindedVote;
  }

  // creates election with a predetermined organizer public key, that is used for verification
  constructor (string _question) public {
    question = _question;
    generatorPoint[0] = 1;
    generatorPoint[1] = 2;
    pubKeyOfOrganizer[0] = 0x1a619cedd96d8ecda3e1a09a577dc3f04422fa54a79b3a53ca5a077fe8b3dbf8;
    pubKeyOfOrganizer[1] = 0x24f4f2f8f95269d63d7cb286934796d9e69ef2b6907d78e8d6ddc6e76cdd748d;
  }

  // blinded message is recorded in order to verify whether the Organizer has provided a correct signature on the blinded msg
  function requestBlindSig(uint256 blindedVote) public {
    require(eligibleVoters[msg.sender].eligible);
    blindedVotes[blindedVote] = msg.sender;
    emit RequestToBlindlySign(msg.sender);
  }

  // requested blindSig is recorded on the blockchain for auditing purposes
  function writeBlindSig(address _voter, uint256 blindSig) onlyOwner public {
    eligibleVoters[_voter].signedBlindedVote = blindSig;
    eligibleVoters[_voter].eligible = false;
  }

  // if the blind signature hasn't been used yet and is correct, the vote is valid
  function Vote(uint256 choiceCode, uint256 blindedVote, uint256 strippedSignedVote) public {
    require(!usedSignatures[blindedVote]);
    usedSignatures[blindedVote] = true;
    verifyBlindSig(choiceCode, blindedVote, strippedSignedVote);
    votes[choiceCode] = votes[choiceCode].add(1);

    emit voteSuccess(msg.sender,choiceCode);
  }

  // organizer can add eligible voters
  function addEligibleVoter(address _voter) onlyOwner public {
    require(!eligibleVoters[_voter].eligible);
    eligibleVoters[_voter].eligible = true;
  }

  // organizer can remove voters
  function removeEligibleVoter(address _voter) onlyOwner public {
    require(eligibleVoters[_voter].eligible);
    eligibleVoters[_voter].eligible = false;
  }

  // converts uint to string
  function uintToString(uint v) pure public returns (string str) {
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

  // the core of the contract: on-chain ECC blind signature verification
  function verifyBlindSig(uint256 vote, uint256 blindedVote, uint256 strippedSignedVote) public {
    uint[2] memory cP = eccPrecompiles.ecmul(pubKeyOfOrganizer[0], pubKeyOfOrganizer[1], blindedVote);
    uint[2] memory sG = eccPrecompiles.ecmul(generatorPoint[0], generatorPoint[1], strippedSignedVote);

    uint[2] memory sum = eccPrecompiles.ecadd(cP[0], cP[1], sG[0], sG[1]);

    uint projection = sum[0] % n;

    require(blindedVote == uint(keccak256(uintToString(vote),uintToString(projection))));
  }

}