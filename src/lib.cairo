// Follows implementation here
// https://blog.openmined.org/the-paillier-cryptosystem/

mod paillier {
    fn pow(x: u256, p: u256, mod_: u256) -> u256 {
        let mut g_m = x;
        let mut mi = 1;
        loop {
            if mi == p {
                break;
            }
            g_m = (g_m * x) % mod_;
            mi += 1;
        };

        g_m
    }

    fn encrypt(g: u256, m: u256, r: u256, n: u256) -> u256 {
        assert(g < 0x10000000000000000, 'g should be < 2^64');
        assert(m < 0x10000000000000000, 'm should be < 2^64');
        assert(n < 0x10000000000000000, 'n should be < 2^64');
        assert(r < 0x10000000000000000, 'r should be < 2^64');
        let n2 = n * n;
        (pow(g, m, n2) * pow(r, n, n2)) % n2
    }

    fn decrypt() {}
}

#[cfg(test)]
mod tests {
    use super::paillier;
    use debug::PrintTrait;

    // These are toy values, with no real security
    const p: u256 = 13;
    const q: u256 = 17;
    const n: u256 = 221;
    const lambda: u256 = 48;
    const g: u256 = 4886;
    const mu: u256 = 15;

    #[test]
    #[available_gas(151587300)]
    fn test_encryption() {
        let m = 123;
        let r = 666;
        let c_expected = 25889;
        assert(paillier::encrypt(g, m, r, n) == c_expected, 'incorrect c');
    }
}
