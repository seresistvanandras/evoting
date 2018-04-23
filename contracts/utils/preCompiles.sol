library eccPrecompiles {

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

//bigModexp
    function expmod(uint256 base, uint256 e, uint256 m) public constant returns (uint256 o) {
        // are all of these inside the precompile now?

        assembly {
        // define pointer
            let p := mload(0x40)
        // store data assembly-favouring ways
            mstore(p, 0x20)             // Length of Base
            mstore(add(p, 0x20), 0x20)  // Length of Exponent
            mstore(add(p, 0x40), 0x20)  // Length of Modulus
            mstore(add(p, 0x60), base)  // Base
            mstore(add(p, 0x80), e)     // Exponent
            mstore(add(p, 0xa0), m)     // Modulus
        // call modexp precompile! -- old school gas handling
            let success := call(sub(gas, 2000), 0x05, 0, p, 0xc0, p, 0x20)
        // gas fiddling
            switch success case 0 {
                revert(0, 0)
            }
        // data
            o := mload(p)
        }

    }
}
