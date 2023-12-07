#[starknet::interface]
trait IPallierVoting<T> {
    // Make a proposal
    fn proposal(ref self: T, proposal: Proposal);
    // Make a vote
    fn vote(ref self: T, vote: Vote);
}

#[derive(Serde, Copy, Drop, starknet::Store)]
struct Proposal {
    id: u64,
    program_hash: u256,
}

#[derive(Serde, Copy, Drop, starknet::Store)]
struct Vote {
    options: u8,
    program_hash: u256,
}

#[starknet::contract]
mod PallierVoting {
    use traits::Into;
    use starknet::ContractAddress;

    #[storage]
    struct Storage {
        proposals: LegacyMap<u64, super::Proposal>,
        votes: LegacyMap<(ContractAddress, u64), super::Vote>,
    }

    #[abi(embed_v0)]
    impl VotingImpl of super::IPallierVoting<ContractState> {
        fn proposal(ref self: ContractState, proposal: super::Proposal) {}
        fn vote(ref self: ContractState, vote: super::Vote) {}
    }
}
