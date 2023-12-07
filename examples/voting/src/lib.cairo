#[starknet::interface]
trait IPallierVoting<T> {
    // Make a proposal
    fn proposal(self: @T, proposal: Proposal);
    // Make a vote
    fn vote(ref self: T, vote: Vote);
}

struct Proposal {
    id: u64,
    program_hash: u256,
}

#[derive(Store)]
struct Vote {
    options: u8,
    program_hash: u256,
}
