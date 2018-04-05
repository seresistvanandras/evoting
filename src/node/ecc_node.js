var crypto = require('crypto')
var BigInteger = require('bigi') //npm install --save bigi@1.4.2
var ecurve = require('ecurve') //npm install --save ecurve@1.0.0
var cs = require('coinstring') //npm install --save coinstring@2.0.0
var createKeccakHash = require('keccak')


function random(bytes){
    do {
        var k = BigInteger.fromByteArrayUnsigned(crypto.randomBytes(bytes));
    } while (k.toString() == "0" && k.gcd(n).toString() != "1")
    return k;
}


/*
function random(bytes){
    do {
        var k = BigInteger.fromByteArrayUnsigned(crypto.randomBytes(bytes));
    } while (k.toString() != "13")
    return k;
}
*/

function isOnCurve (x,y) {

    var x = x;
    var y = y;
    var a = ecurve.getCurveByName('secp256k1').a;
    var b = ecurve.getCurveByName('secp256k1').b;
    var p = ecurve.getCurveByName('secp256k1').p;

    // Check that xQ and yQ are integers in the interval [0, p - 1]
    if (x.signum() < 0 || x.compareTo(p) >= 0) return false
    if (y.signum() < 0 || y.compareTo(p) >= 0) return false

    // and check that y^2 = x^3 + ax + b (mod p)
    var lhs = y.square().mod(p);
    var rhs = x.pow(3).add(a.multiply(x)).add(b).mod(p);
    return lhs.equals(rhs);
}

function multiply(inp,k){
    var str = inp.multiply(k).toString().replace("(","").replace(")","");
    var arr = str.split(",").map(val => String(val));
    arr [0] = BigInteger.fromBuffer(arr[0]);
    arr [1] = BigInteger.fromBuffer(arr[1]);

    return ecurve.Point.fromAffine(ecparams,arr[0],arr[1]);
}

function add(inp,k){
    var str = inp.add(k).toString().replace("(","").replace(")","");
    var arr = str.split(",").map(val => String(val));
    arr [0] = BigInteger.fromBuffer(arr[0]);
    arr [1] = BigInteger.fromBuffer(arr[1]);

    return ecurve.Point.fromAffine(ecparams,arr[0],arr[1]);
}

function toHex(inp){
    return BigInteger.fromBuffer(inp.toString(),"hex").toHex();
}

function keccak256(inp){
    return createKeccakHash('keccak256').update(inp.toString()).digest('hex');
}

var privateKey = new Buffer("1184cd2cdd640ca42cfc3a091c51d549b2f016d454b2774019c2b2d2e08529fd", 'hex')


var m  = "1";

var ecparams = ecurve.getCurveByName('altBN128'); //or secp256k1
var curvePt = ecparams.G.multiply(BigInteger.fromBuffer(privateKey));
var x = curvePt.affineX.toBuffer(32);
var y = curvePt.affineY.toBuffer(32);

var G = ecparams.G;
var n = ecparams.n;


/* STEP 1
The signer randomly selects an integer k ∈ Zn
, calculates R = kG, and then transmits R to the
requester
*/

k = random(32);

var R = multiply(G,k);


/* Solidity test helper fucntions
var zwei = BigInteger.fromBuffer(new Buffer("2"));
var drei = BigInteger.fromBuffer(new Buffer("3"));

var z = BigInteger.fromBuffer(new Buffer("9075b4ee4d4788cabb49f7f81c221151fa2f68914d0aa833388fa11ff621a970", 'hex'));
var zSquare = (z.pow(2).mod(ecparams.p))
var zCube = (z.pow(3).mod(ecparams.p))
*/

/* STEP 2
The requester randomly selects two integers γ and δ ∈ Zn, blinds the message, and then
calculates point A = kG + γG + δP = (x, y), t = x (mod n). If t equals zero, then γ and δ should
be reselected. The requester calculates c = SHA256 (m || t), c’ = c − δ, where SHA256 is a
novel hash function computed with 32-bit words and c’ is the blinded message, and then sends
c’ to the signer.
*/

var γ = random(32);

var δ = random(32);

var A = add(add(R,multiply(G,γ)),multiply(curvePt,δ));

var t = A.x.mod(n).toString();

var c = BigInteger.fromHex(keccak256(m+t.toString()));

console.log(keccak256(m+t.toString()));

var cBlinded = c.subtract(δ);

/* STEP 3
The signer calculates the blind signature s’ = k − c’d, and then sends it to the requester.
*/

var sBlind = k.subtract(cBlinded.multiply(BigInteger.fromBuffer(privateKey)));

/* STEP 4
The requester calculates s = s’ + γ, and (c, s) is the signature on m.
*/

var s = sBlind.add(γ);
//console.log(s.mod(n).toHex())

/* STEP 5
Both the requester and signer can verify the signature (c, s) through the formation
c = SHA256(m || Rx(cP + sG) mod n)
*/

var toHash = add(multiply(curvePt,c.mod(n)),multiply(ecparams.G,s.mod(n))).x.mod(n)
console.log("c: ")
console.log(BigInteger.fromHex(keccak256(m+toHash)).toString());

console.log("s: ")
console.log(s.mod(n).toString())

console.log("hashvote: ")
console.log(BigInteger.fromHex(keccak256(m)).toString())

//1,1,"90743482286830539503240959006302832933333810038750515972785732718729991261126","36569675563270980802762714306156177901149277261141117320653538205171502807189","6584969667293602680567734539575163142389903381909774456551685991814241531484"
/*
console.log("Generator point: ", G.toString())
console.log("Doubling the generatorPoint", multiply(G,BigInteger.fromBuffer(new Buffer("02", 'hex'))).toString())
console.log("Doubling with self-addition",add(G,G).toString())
*/

