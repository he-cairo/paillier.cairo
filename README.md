# Paillier's homomorphic cryptosystem in Cairo

Performs Paillier encryption and decryption in Cairo.

Most of the stuff is shamelessly copied from Will Clark's article on [blog.openmined.org](https://blog.openmined.org/the-paillier-cryptosystem/)

## Key generation

Key generation is not included in the Cairo code.
Key generation works as follows:

* Pick two large prime numbers `p` and `q`, randomly and independently. Confirm that `gcd(pq,(p−1)(q−1))` is `1`. If not, start again.
  - `gcd(x,y)` outputs the greatest common divisor of x and y.
* Compute `n = pq`.
* Define function `L(x) = (x − 1) / n`.
* Compute `lambda`, λ as `lcm(p−1, q−1)`.
  - `lcm(x,y)` outputs the least common multiple of x and y.
* Pick a random integer `g` in the set of integers between `1` and `n**2`.
* Calculate the modular multiplicative inverse mu, `μ = ( L(gλmodn2))−1 mod n`. If μ does not exist, start again from step 1.
* The public key is `(n, g)`. Use this for encryption.
* The private key is `lambda`, λ. Use this for decryption.

## Encryption

Encryption works for any `m` in the range `0 ≤ m < n`:


1. Pick a random `r` in range of `0 < r < n`
2. Compute ciphertext `c = g**m * r**n mod n**2`

## Decryption

For cyphertext `c` in range of `0 < c < n**2`,
For `L(x) = (x − 1) / n`,
`plaintext = L( c**lambda mod n**2 ) * μ mod n`
OR `plaintext = (c**lambda mod n**2 - 1) / n * μ mod n`
