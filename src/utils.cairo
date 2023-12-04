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
