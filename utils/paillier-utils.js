const paillierBigint = require("paillier-bigint");

async function paillierTest(m1, m2) {
    // (asynchronous) creation of a random private, public key pair for the Paillier cryptosystem
    const {
        publicKey,
        privateKey
    } = await paillierBigint.generateRandomKeys(keyBitlength);

    console.log(`
    // Public key params
    const n: u256 = ${publicKey.n.toString()};
    const g: u256 = ${publicKey.g.toString()};
    // Private key params
    const lambda: u256 = ${privateKey.lambda.toString()};
    const mu: u256 = ${privateKey.mu.toString()};`);

    // Optionally, you can create your public/private keys from known parameters
    // const publicKey = new paillierBigint.PublicKey(n, g)
    // const privateKey = new paillierBigint.PrivateKey(lambda, mu, publicKey)

    // encryption/decryption
    const c1 = publicKey.encrypt(m1);

    // homomorphic addition of two ciphertexts (encrypted numbers)
    const c2 = publicKey.encrypt(m2);
    const encryptedSum = publicKey.addition(c1, c2);

    console.log(`
    // Inputs
    let m1: u256 = ${m1};
    let m2: u256 = ${m2};
    // Input ciphers
    let c1: u256 = ${c1.toString()};
    let c2: u256 = ${c2.toString()};`);

    console.log(`
    // Sum cipher
    let c_sum = ${encryptedSum.toString()}`);
}

const args = process.argv.slice(2);
const keyBitlength = +args[0] || 64;
const m1 = BigInt(args[1] || 25);
const m2 = BigInt(args[2] || 56);

paillierTest(m1, m2);