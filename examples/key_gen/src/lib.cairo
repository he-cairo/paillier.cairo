use debug::{PrintTrait, print};
use core::traits::Into;
// Public key params
const n: u256 = 11600858214793136449;
const g: u256 = 124315745551995008136633994173642686987;
// // Private key params
const lambda: u256 = 644492122645033170;
const mu: u256 = 9083018135366523880;

fn generate_vote_hidings(vote: u256, random: u256) -> Array<felt252> {
    assert(vote < 2, 'Only 2');

    let n1 = paillier::encrypt(1, random.into(), n, g);
    let n0 = paillier::encrypt(0, random.into(), n, g);

    if 0 == vote {
        array![n1.try_into().unwrap(), n0.try_into().unwrap(),]
    } else {
        array![n0.try_into().unwrap(), n1.try_into().unwrap(),]
    }
}

// Run:
// scarb cairo-run --available-gas 3000000000
fn main() {
    let a = generate_vote_hidings(0, 23432);
    let b = generate_vote_hidings(1, 43256);
    let c = generate_vote_hidings(0, 97889);

    'HIDINGS'.print();

    print(a);
    print(b);
    print(c);
}

#[cfg(test)]
mod decryption {
    use super::{lambda, n, mu};
    use debug::{PrintTrait, print};
    // Run:
    // scarb test
    #[test]
    #[available_gas(3000000000)]
    fn decrypt() {
        let y = 0x3efa6507a77e74f0b6ca76d9ea49bdef;
        let x = 0x4fd5ba994731daa299bd4d1b6c86de3f;
        paillier::decrypt(x, lambda, n, mu).low.print();
        paillier::decrypt(y, lambda, n, mu).low.print();
    }
}
