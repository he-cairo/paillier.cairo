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

// Define a function  L(x) = ( x - 1 ) / n
fn L(x: u256, n: u256) -> u256 {
    (x - 1) / n
}

#[cfg(test)]
mod tests {
    use debug::PrintTrait;
    use super::{pow, L};

    #[test]
    #[available_gas(100000000)]
    fn test_pow() {
        assert(625 == pow(5, 4, 0x100000), 'incorrect 5**4');
        assert(6561 == pow(3, 8, 0x100000), 'incorrect 3**8');
    }
}
