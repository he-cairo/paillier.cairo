const paillierBigint = require("paillier-bigint");

async function paillierTest(m1, m2) {
    // (asynchronous) creation of a random private, public key pair for the Paillier cryptosystem
    const { publicKey, privateKey } = await paillierBigint.generateRandomKeys(
        64 // key size in bits
    );

    console.log(
        "Public key parameters: \n",
        "n - ",
        publicKey.n.toString(),
        "\n",
        "g - ",
        publicKey.g.toString()
    );
    console.log(
        "Private key parameters: \n",
        "lambda - ",
        privateKey.lambda.toString(),
        "\n",
        "mu - ",
        privateKey.mu.toString()
    );

    // Optionally, you can create your public/private keys from known parameters
    // const publicKey = new paillierBigint.PublicKey(n, g)
    // const privateKey = new paillierBigint.PrivateKey(lambda, mu, publicKey)

    // encryption/decryption
    const c1 = publicKey.encrypt(m1);

    // homomorphic addition of two ciphertexts (encrypted numbers)
    const c2 = publicKey.encrypt(m2);
    const encryptedSum = publicKey.addition(c1, c2);

    console.log("m1 - ", m1.toString());
    console.log("m2 - ", m2.toString());

    console.log("c1 - ", c1.toString());
    console.log("c2 - ", c2.toString());

    console.log("Encrypted sum - ", encryptedSum.toString());
}

const args = process.argv.slice(2);
const m1 = BigInt(args[0]);
const m2 = BigInt(args[1]);

if (m1 === undefined || m2 === undefined) {
    console.error("Please provide both m1 and m2 values");
    process.exit(1);
}

paillierTest(m1, m2);