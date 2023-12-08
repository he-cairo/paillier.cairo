use starknet::ClassHash;

#[starknet::interface]
trait IPallierVoting<T> {
    // Update contract implementation
    fn replace_class(ref self: T, class_hash: ClassHash);
    // Make a proposal
    fn proposal(ref self: T, program_hash: u256, n: u256,);
    // Make a vote
    fn vote(ref self: T, proposal_id: u64, y_vote: u128, n_vote: u128,);
    // Get proposal details
    fn get_proposal(self: @T, proposal_id: u64) -> Proposal;
}

#[derive(Serde, Copy, Drop, starknet::Store)]
struct Proposal {
    program_hash: u256, // Cairo program hash for proofs
    n: u256, // Homomorphic Public key
    y_votes: u128,
    n_votes: u128,
}

#[starknet::contract]
mod PallierVoting {
    use traits::Into;
    use starknet::{ContractAddress, get_caller_address, ClassHash};
    use starknet::syscalls::replace_class_syscall;
    use super::Proposal;

    #[storage]
    struct Storage {
        proposals: LegacyMap<u64, Proposal>,
        proposal_count: u64,
        governor: ContractAddress,
    }

    #[constructor]
    fn constructor(ref self: ContractState, governor: ContractAddress) {
        self.governor.write(governor);
    }

    fn mk256(low: u128) -> u256 {
        u256 { low, high: 0 }
    }

    #[abi(embed_v0)]
    impl VotingImpl of super::IPallierVoting<ContractState> {
        fn replace_class(ref self: ContractState, class_hash: ClassHash) {
            replace_class_syscall(class_hash);
        }
        fn proposal(ref self: ContractState, program_hash: u256, n: u256,) {
            assert(self.governor.read() == get_caller_address(), 'only governor');
            let mut i = self.proposal_count.read();
            i += 1;
            self.proposal_count.write(i);
            self.proposals.write(i, Proposal { program_hash, n, y_votes: 1, n_votes: 1 });
        }
        fn vote(ref self: ContractState, proposal_id: u64, y_vote: u128, n_vote: u128,) {
            let mut proposal = self.proposals.read(proposal_id);
            proposal
                .n_votes = paillier::add(mk256(proposal.n_votes), mk256(n_vote), proposal.n)
                .low; // votes are 64 bits so won't overflow
            proposal
                .y_votes = paillier::add(mk256(proposal.y_votes), mk256(y_vote), proposal.n)
                .low; // votes are 64 bits so won't overflow
            self.proposals.write(proposal_id, proposal);
        }
        fn get_proposal(self: @ContractState, proposal_id: u64) -> super::Proposal {
            self.proposals.read(proposal_id)
        }
    }
}
