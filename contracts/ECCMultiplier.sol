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

}
