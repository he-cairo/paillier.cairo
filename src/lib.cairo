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
mod tests_toy {
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
        let a_ = paillier::encrypt(a, r, n, g);
        let b_ = paillier::encrypt(b, r, n, g);
        let c_ = paillier::add(a_, b_, n);
        // When two ciphertexts are multiplied, the result decrypts to the sum of their plaintexts
        assert(a + b == paillier::decrypt(c_, lambda, n, mu), 'invalid homomorphic addition');
    }
}

#[cfg(test)]
mod tests_64bits {
    use debug::PrintTrait;

    // Public key params
    const n: u256 = 0xc818f5be9eb17d3b;
    const g: u256 = 193279223797371404001905592506928440800;
    // Private key params
    const lambda: u256 = 7209272198853933120;
    const mu: u256 = 8334459261319212077;

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
        let a_ = paillier::encrypt(a, r, n, g);
        // a_.low.print(); // 0x2a17018d0ca85295fe8c3a333befc2be
        let b_ = paillier::encrypt(b, r, n, g);
        // b_.low.print(); // 0x3e5db27c1cede9ebd604b81b329db4c3
        let c_ = paillier::add(a_, b_, n);
        // c_.low.print(); // 0x546d56db02d4802f1f604d41e341ae34

        // multiplication of two ciphertexts decrypts to the sum of their plaintexts
        assert(a + b == paillier::decrypt(c_, lambda, n, mu), 'invalid homomorphic addition');
    }

    #[test]
    #[available_gas(100000000)]
    fn test_huge_addition() {
        let a = 0x1d35034ca8ca57;
        let b = 0x2d36854ced30f1;
        let c = a + b;
        let r = 66;
        let a_ = paillier::encrypt(a, r, n, g);
        // a_.low.print(); // 0x293f08a498d9bc8371677f741fa08d97
        let b_ = paillier::encrypt(b, r, n, g);
        // b_.low.print(); // 0x674bdf867f1e68bf8b9af3ff8ecdaa31
        let c_ = paillier::add(a_, b_, n);
        // c_.low.print(); // 0x720d9178ebcc469e4e1dbd5f9b2e2fdc

        // multiplication of two ciphertexts decrypts to the sum of their plaintexts
        assert(a + b == paillier::decrypt(c_, lambda, n, mu), 'invalid homomorphic addition');
    }
}
