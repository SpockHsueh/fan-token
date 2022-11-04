address admin {

  module fantoken {
    use aptos_framework::coin;
    use std::signer;
    use std::string;

    struct Fan{}

    struct CoinCapablities<phantom Fan> has key {
      mint_capability: coin::MintCapability<Fan>,
      burn_capability: coin::BurnCapability<Fan>,
      freeze_capability: coin::FreezeCapability<Fan>
    }

    const E_NO_ADMIN: u64 = 0;
    const E_NO_CAPABILITIES: u64 = 1;
    const E_HAS_CAPABILITIES: u64 = 2;

    public entry fun init_fan(account: &signer) {
      let (burn_capability, freeze_capability, mint_capability) = coin::initialize<Fan> (
        account,
        string::utf8(b"Fan Token"),
        string::utf8(b"Fan"),
        18,
        true
      );

      assert!(signer::address_of(account) == @admin, E_NO_ADMIN);
      assert!(!exists<CoinCapablities<Fan>>(@admin), E_HAS_CAPABILITIES);

      move_to<CoinCapablities<Fan>>(account, CoinCapablities<Fan>{mint_capability, burn_capability, freeze_capability});      
    }

    public fun mint(account: &signer, amount: u64): coin::Coin<Fan> acquires CoinCapablities {
      let account_address = signer::address_of(account);
      assert!(account_address == @admin, E_NO_ADMIN);
      assert!(exists<CoinCapablities<Fan>>(account_address), E_NO_CAPABILITIES);

      let mint_capability = &borrow_global<CoinCapablities<Fan>>(account_address).mint_capability;
      coin::mint<Fan>(amount, mint_capability)
    }

    public fun burn(coins: coin::Coin<Fan>) acquires CoinCapablities {
      let burn_capability = &borrow_global<CoinCapablities<Fan>>(@admin).burn_capability;
      coin::burn<Fan>(coins, burn_capability);
    }
  }
}