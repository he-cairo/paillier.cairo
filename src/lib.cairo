// Follows implementation here
// https://blog.openmined.org/the-paillier-cryptosystem/

mod utils;

fn encrypt(m: u256, r: u256, n: u256, g: u256) -> u256 {
    assert(g < 0x100000000000000000000000000000000, 'g should be < 2^128');
    assert(m < 0x10000000000000000, 'm should be < 2^64');
    assert(n < 0x10000000000000000, 'n should be < 2^64');
    assert(r < 0x10000000000000000, 'r should be < 2^64');
    let n2 = n * n;
    utils::pow(g, m, n2) * utils::pow(r, n, n2) % n2
}

fn decrypt(c: u256, lambda: u256, n: u256, mu: u256) -> u256 {
    assert(c < 0x10000000000000000, 'c should be < 2^64');
    assert(lambda < 0x10000000000000000, 'lambda should be < 2^64');
    assert(n < 0x10000000000000000, 'n should be < 2^64');
    assert(mu < 0x10000000000000000, 'mu should be < 2^64');
    let n2 = n * n;
    utils::L(utils::pow(c, lambda, n2), n) * mu % n
}


#[cfg(test)]
mod tests {
    use debug::PrintTrait;

    // These are toy values, with no real security
    const p: u256 = 13;
    const q: u256 = 17;
    const n: u256 = 221;
    const lambda: u256 = 48;
    const g: u256 = 4886;
    const mu: u256 = 159;

    #[test]
    #[available_gas(100000000)]
    fn test_encryption() {
        let m = 123;
        let r = 666;
        let c_expected = 25889;
        assert(paillier::encrypt(m, r, n, g) == c_expected, 'incorrect c');
    }

    #[test]
    #[available_gas(100000000)]
    fn test_decryption() {
        let c = 25889;
        let m_expected = 123;
        assert(paillier::decrypt(c, lambda, n, mu) == m_expected, 'incorrect m');
    }

    #[test]
    #[available_gas(100000000)]
    fn test_addition() {
        let a = 25;
        let b = 88;
        let c = a + b;
        let r = 666;
        let a_ = paillier::encrypt(25, r, n, g); // = 0xb5a0
        let b_ = paillier::encrypt(88, r, n, g); // = 0x32e3
        // When two ciphertexts are multiplied, the result decrypts to the sum of their plaintexts
        assert(a + b == paillier::decrypt(a_ * b_, lambda, n, mu), 'invalid homomorphic addition');

        // Strange fact: a_ * b_ != c_, but both decrypt to a + b
        let c_ = paillier::encrypt(a + b, r, n, g); // = 0xbe1e
        assert(a + b == paillier::decrypt(c_, lambda, n, mu), 'invalid homomorphic addition');
    }
}
