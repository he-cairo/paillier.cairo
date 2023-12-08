#[cfg(test)]
mod tests {
    use array::ArrayTrait;
    use core::result::ResultTrait;
    use core::traits::Into;
    use option::OptionTrait;
    use starknet::syscalls::{deploy_syscall, ClassHash, SyscallResult};
    use traits::TryInto;

    use test::test_utils::assert_eq;

    use pallier_voting::{PallierVoting, IPallierVotingDispatcher, IPallierVotingDispatcherTrait};

    use debug::{print, PrintTrait};

    #[test]
    #[available_gas(10000000000)]
    fn test_flow() {
        let calldata = array![0x0];
        let deploy_call = deploy_syscall(
            PallierVoting::TEST_CLASS_HASH.try_into().unwrap(), 0, calldata.span(), false
        );

        let (address0, _) = deploy_call.unwrap();

        let mut contract0 = IPallierVotingDispatcher { contract_address: address0 };
    }
}
