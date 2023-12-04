use debug::PrintTrait;

fn pow_cache(x: u256, p_upto: u256, mod_: u256) -> Span<u256> {
    let p_upto_half = p_upto;
    let mut pow_cache = array![1, x];
    let mut pow = 1_u256;
    let mut x_last_pow = x;
    loop {
        pow = pow + pow;
        if pow > p_upto_half {
            break;
        }
        x_last_pow = x_last_pow * x_last_pow % mod_;
        pow_cache.append(x_last_pow);
    };
    pow_cache.span()
}

fn pow(x: u256, p: u256, mod_: u256) -> u256 {
    let mut g_m = x;
    let mut mi = 1;
    loop {
        if mi == p {
            break;
        }
        g_m = g_m * x % mod_;
        mi += 1;
    };

    g_m
}

// Define a function  L(x) = ( x - 1 ) / n
fn L(x: u256, n: u256) -> u256 {
    (x - 1) / n
}

#[cfg(test)]
mod tests {
    use core::array::SpanTrait;
    use debug::PrintTrait;
    use super::{pow, pow_cache, L};

    #[test]
    #[available_gas(100000000)]
    fn test_pow() {
        assert(625 == pow(5, 4, 0x100000), 'incorrect 5**4');
        assert(6561 == pow(3, 8, 0x100000), 'incorrect 3**8');
    }

    #[test]
    #[available_gas(1000000000)]
    fn test_pow_cache() {
        let cache = pow_cache(3, 25, 0x100000000000000);
        assert(cache.len() == 6, 'incorrect cache len');
        assert(*cache[0] == 1, 'incorrect cache 0');
        assert(*cache[1] == 3, 'incorrect cache 1');
        assert(*cache[2] == 9, 'incorrect cache 2');
        assert(*cache[3] == 81, 'incorrect cache 3');
        assert(*cache[4] == 6561, 'incorrect cache 4');
        assert(*cache[5] == 43046721, 'incorrect cache 5');
    }
}
