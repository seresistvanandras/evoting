pragma solidity ^0.4.18;

import 'zeppelin-solidity/contracts/ownership/Ownable.sol';

contract ElectionECCwPrecompile is Ownable  {
  mapping (address => Voter) public eligibleVoters;
  mapping (uint256 => address) public blindedVotes;
  mapping (uint256 => uint256) public votes; //counts the votes for specific options

  string public question;

  //https://github.com/ethereum/EIPs/pull/213

  //Y^2 = X^3 + 3
  uint constant p = 0x30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd47; //field modulus

  uint constant n = 0x30644e72e131a029b85045b68181585d2833e84879b9709143e1f593f0000001; //curve order

  // Base point (generator) G

  //secp256k1 generator point
  uint256[2] public generatorPoint; //in affine coordinates
  uint256[2] public pubKeyOfOrganizer; //in affine coordinates

  struct Voter {
    bool eligible;
    uint256 blindedVote;
    uint256 signedBlindedVote;
  }

  event RequestToBlindlySign(address indexed voter);
  event voteSuccess(address indexed voter, uint256 hashOfVote);
  event debug(uint256 vote, uint256 votehash);

  //constructor
  function ElectionECCwPrecompile (string _question) public {
    question = _question;
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
    uint[2] memory cP = ecmul(pubKeyOfOrganizer[0], pubKeyOfOrganizer[1], c);
    uint[2] memory sG = ecmul(generatorPoint[0], generatorPoint[1], s);

    uint[2] memory sum = ecadd(cP[0], cP[1], sG[0], sG[1]);

    uint projection = sum[0] % n;

    require(c == uint(keccak256(uintToString(m),uintToString(projection))));
  }

  function ecmul(uint256 x, uint256 y, uint256 scalar) public constant returns(uint256[2] p) {

  // With a public key (x, y), this computes p = scalar * (x, y).
  uint256[3] memory input;
  input[0] = x;
  input[1] = y;
  input[2] = scalar;

  assembly {
    // call ecmul precompile
    if iszero(call(not(0), 0x07, 0, input, 0x60, p, 0x40)) {
      revert(0, 0)
    }
  }

}

function ecadd(uint256 x1, uint256 y1, uint256 x2, uint256 y2) public constant returns (uint256[2] p) {
// are all of these inside the precompile now?
uint256[4] memory input;
input[0] = x1;
input[1] = y1;
input[2] = x2;
input[3] = y2;

assembly {
 if iszero(call(not(0), 0x06, 0, input, 0x80, p, 0x40)) {
   revert(0, 0)
 }
}

}

}
