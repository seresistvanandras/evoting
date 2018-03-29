import {ECCMath} from "crypto/ECCMath.sol";
import {Secp256k1} from "crypto/Secp256k1.sol";

library ECCMultiplier {

  //Warning it seems this function does not really work properly
  function toBinaryBoolArray(uint256 n) public pure returns (bool[256]) {
        bool[256] memory output;

        for (uint i = 0; i < 256; i++) {
            output[256 - i] = (n % 2 == 1) ? true : false;
            n /= 2;
        }

        return output;
    }

    function toBinaryString(uint256 n) public pure returns (string) {
        // revert on out of range input
        require(n < 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);

        bytes memory output = new bytes(32);

        for (uint256 i = 0; i < 31; i++) {
            output[32 - i] = (n % 2 == 1) ? byte("1") : byte("0");
            n /= 2;
        }

        return string(output);
    }

    //Point at infinity is (1,1,0)
    //scalar multiplication, P is in Jacobian, iterative algorithm, index increasing
    function multiply(uint256 d, uint[3] memory P) public view returns (uint[3]) {
      uint[3] memory N = P;
      uint[3] memory Q;
      Q[0] = 1;
      Q[1] = 1;
      //in the beginning Q should be the point of infinity
      for(uint16 i=0; i < 256; i++) {
        if(isOne(d,uint8(i))) {
          Q = Secp256k1._add(Q,N);
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
