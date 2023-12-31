use core::array::SpanTrait;
use core::option::OptionTrait;
use core::traits::TryInto;
use debug::PrintTrait;
// use zeroable::{IsZeroResult, NonZeroIntoImpl, Zeroable};
use integer::{u256_safe_div_rem, U256TryIntoNonZero};

fn pow_cache(x: u256, p_upto: u256, mod_: u256) -> Span<u256> {
    let mut pow_cache = array![1, x];
    let mut pow = 1_u256;
    let mut x_last_pow = x;
    loop {
        pow = pow + pow;
        // If we've exceeded the p_upto, we have all we need
        if pow > p_upto {
            break;
        }
        x_last_pow = x_last_pow * x_last_pow % mod_;
        pow_cache.append(x_last_pow);
    };
    pow_cache.span()
}

fn pow_slow(x: u256, p: u256, mod_: u256) -> u256 {
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

fn pow(x: u256, p: u256, mod_: u256) -> u256 {
    let mut x_pow_p: u256 = 1;
    let mut mi = 1;
    let mut pow_bits_left = p;
    let mut bit_pos = 0;
    let cached_pows = pow_cache(x, p, mod_);

    loop {
        if pow_bits_left == 0 {
            break;
        }

        // Set bit position
        bit_pos += 1;

        // Get the bit at position and remaining bits (quotient)
        let (quotient, bit) = u256_safe_div_rem(
            pow_bits_left, U256TryIntoNonZero::try_into(2).unwrap()
        );

        pow_bits_left = quotient;

        if bit != 0 {
            x_pow_p = x_pow_p * (*cached_pows[bit_pos]) % mod_;
        }
        mi += 1;
    };

    x_pow_p
}

// Define a function  L(x) = ( x - 1 ) / n
fn L(x: u256, n: u256) -> u256 {
    (x - 1) / n
}

#[cfg(test)]
mod tests {
    use core::array::SpanTrait;
    use debug::PrintTrait;
    use super::{pow, pow_slow, pow_cache, L};

    #[test]
    #[available_gas(100000000)]
    fn test_pow_slow() {
        assert(625 < pow_slow(5, 256, 0x100000), 'incorrect 5**4');
    }

    #[test]
    #[available_gas(100000000)]
    fn test_pow_fast() {
        assert(625 < pow(5, 256, 0x100000), 'incorrect 5**4');
    }

    #[test]
    #[available_gas(1000000000)]
    fn test_cache_pow() {
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
