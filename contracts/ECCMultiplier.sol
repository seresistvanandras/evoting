import {ECCMath} from "crypto/ECCMath.sol";
import {Secp256k1} from "crypto/Secp256k1.sol";

library ECCMultiplier {

  function toBinaryBoolArray(uint256 n) public pure returns (bool[256]) {
        bool[256] memory output;

        for (uint i = 0; i < 256; i++) {
            output[256 - i] = (n % 2 == 1) ? true : false;
            n /= 2;
        }

        return output;
    }

    //scalar multiplication, P is in Jacobian
    function multiply(uint256 d, uint[3] memory P) public view returns (uint[3]) {
      bool[256] memory binaryRep = toBinaryBoolArray(d);
      uint[3] memory N = P;
      uint[3] memory Q;
      for(uint i=0; i < 256; i++) {
        if(binaryRep[255-i]) {
          Q = Secp256k1._add(P,Q);
        }
        N = Secp256k1._double(N);
      }
      return Q;
    }

    function shiftLeft(uint a, uint8 n) public view returns (uint) {
        return a << n;
    }

    function isOne(uint a, uint8 n) public view returns (bool) {
        return convertBytesToBytes32(toBytesEth(a)) & convertBytesToBytes32(toBytesEth(shiftLeft(0x01,n))) != 0;
    }

    function toBytesEth(uint256 x) public constant returns (bytes) {
        var b = new bytes(32);
        for (uint i = 0; i < 32; i++) {
            b[i] = byte(uint8(x / (2**(8*(31 - i)))));
        }
        return b;
    }

    function convertBytesToBytes32(bytes inBytes) public view returns (bytes32 outBytes32) {
        if (inBytes.length == 0) {
            return 0x0;
        }
        assembly {
            outBytes32 := mload(add(inBytes, 32))
        }
    }

}
