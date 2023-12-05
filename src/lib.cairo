// Follows implementation here
// https://blog.openmined.org/the-paillier-cryptosystem/

mod utils;

// Generate hiding for the value from the public key
fn encrypt(m: u256, r: u256, n: u256, g: u256) -> u256 {
    let n2 = n * n;
    assert(g < n2, 'g should be < n^2');
    assert(m < n, 'm should be < n');
    assert(n < 0x10000000000000000, 'n should be < 2^64');
    assert(r < n, 'r should be < n');
    utils::pow(g, m, n2) * utils::pow(r, n, n2) % n2
}

// Reveal hidings with private key
fn decrypt(c: u256, lambda: u256, n: u256, mu: u256) -> u256 {
    let n2 = n * n;
    assert(c < n2, 'c should be < n2');
    assert(n < 0x10000000000000000, 'n should be < 2^64');
    assert(mu < n, 'mu should be < n');
    utils::L(utils::pow(c, lambda, n2), n) * mu % n
}

// Performs addition on the hidings
fn add(c1: u256, c2: u256, n: u256) -> u256 {
    let n2 = n * n;
    c1 * c2 % n2
}


#[cfg(test)]
mod toy_tests {
    use debug::PrintTrait;

    // These are toy values, with no real security
    // p and q are 13 and 17;
    const n: u256 = 221;
    const lambda: u256 = 48;
    const g: u256 = 4886;
    const mu: u256 = 159;

    #[test]
    #[available_gas(100000000)]
    fn test_encryption_decryption() {
        let m = 123;
        let r = 66;
        let c_expected = 25889;
        let c = paillier::encrypt(m, r, n, g);
        assert(c != m, 'same c');
        assert(paillier::decrypt(c, lambda, n, mu) == m, 'same c');
    }

    #[test]
    #[available_gas(100000000)]
    fn test_addition() {
        let a = 25;
        let b = 88;
        let c = a + b;
        let r = 66;
        let a_ = paillier::encrypt(25, r, n, g);
        let b_ = paillier::encrypt(88, r, n, g);
        let c_ = paillier::add(a_, b_, n);
        // When two ciphertexts are multiplied, the result decrypts to the sum of their plaintexts
        assert(a + b == paillier::decrypt(c_, lambda, n, mu), 'invalid homomorphic addition');

        // Strange fact: a_ * b_ != c_, but both decrypt to a + b
        let c_ = paillier::encrypt(a + b, r, n, g); // = 0xbe1e
        assert(a + b == paillier::decrypt(c_, lambda, n, mu), 'invalid homomorphic addition');
    }
}
