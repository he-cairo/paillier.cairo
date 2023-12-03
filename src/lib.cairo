mod paillier {
    fn encrypt(g: u256, m: u256, r: u256, n: u256) -> u256 {
        assert(g < 0x10000000000000000, 'g should be < 2^64');
        assert(m < 0x10000000000000000, 'm should be < 2^64');
        assert(n < 0x10000000000000000, 'n should be < 2^64');
        assert(r < 0x10000000000000000, 'r should be < 2^64');

        let n2 = n * n;
        let mut g_m = g;
        let mut mi = 1;
        loop {
            if mi == m {
                break;
            }
            g_m = (g_m * g) % n2;
            mi += 1;
        };

        let mut r_n = r;
        let mut ni = 1;
        loop {
            if ni == n {
                break;
            }
            r_n = (r_n * g) % n2;
            ni += 1;
        };

        g_m * r_n % n2
    }

    fn decrypt() {}
}

#[cfg(test)]
mod tests {
    use super::paillier;
    use debug::PrintTrait;

    #[test]
    #[available_gas(100000)]
    fn it_works() {
        paillier::encrypt(11, 5, 53, 127).print()
    }
}
