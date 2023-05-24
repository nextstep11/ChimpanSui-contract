module nft_contract::nft_contract{
    use std::vector;
    use sui::coin::{Self, Coin};
    use sui::balance::{Self, Balance};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    use sui::object::{Self, UID};
    use std::string::{Self, String};
    use sui::sui::SUI;

    struct LaunchpadCap has key, store{
        id: UID
    }

    struct LaunchpadData has store, key{
        id: UID,
        minted: u64,
        base_name: String,
        base_url: String,
        base_url_extension: String,
        base_image_url: String,
        base_image_url_extension: String,
        description: String,
        balance: Balance<SUI>,
        total_nft: u64,
        fund_address: address,
        price: u64,
    }

    struct ChimpanSui has store, key{
        id: UID,
        name: String,
        description: String,
        url: String,
        image_url: String,
    }

    fun init(ctx: &mut TxContext){
        transfer::share_object(LaunchpadData{
            id: object::new(ctx),
            minted: 0,
            base_name: string::utf8(b"ChimpanSui #"),
            base_url: string::utf8(b"https://green-advisory-squid-332.mypinata.cloud/ipfs/QmWncxfvtP5t73PpW5THgAEJ3pn5cAc3TayDKPwWMzxNzX/JSON/"),
            base_url_extension: string::utf8(b".json"),
            base_image_url: string::utf8(b"https://green-advisory-squid-332.mypinata.cloud/ipfs/QmRDEWiMTnkDp8SaGMSwSy1LbY92op8PbN7EXnBRp56u4Q/"),
            base_image_url_extension: string::utf8(b".png"),
            description: string::utf8(b"ChimpanSui is ...."),
            balance: balance::zero<SUI>(),
            total_nft: 4000,
            fund_address: tx_context::sender(ctx),
            price: 0,
        });
        transfer::public_transfer(LaunchpadCap{id: object::new(ctx)}, tx_context::sender(ctx));
    }

    fun num_to_string(index: u64): String{
        let temp : vector<u8> = vector::empty();
        while(index!=0){
            let i = (index % 10 as u8);
            vector::push_back<u8>(&mut temp, i+48);
            index = index / 10;
        };
        vector::reverse(&mut temp);
        string::utf8(temp)
    }

    entry fun mint(launchpad: &mut LaunchpadData, paid: &mut Coin<SUI>, ctx: &mut TxContext){
        balance::join(&mut launchpad.balance, coin::into_balance(coin::split(paid, launchpad.price, ctx)));
        let index = launchpad.minted + 1;
        let str_index = num_to_string(index);
        
        let image_url = launchpad.base_image_url;
        string::append(&mut image_url, str_index);
        string::append(&mut image_url, launchpad.base_image_url_extension);
        
        let name = launchpad.base_name;
        string::append(&mut name, str_index);
        
        let url = launchpad.base_url;
        string::append(&mut url, str_index);
        string::append(&mut url, launchpad.base_url_extension);

        transfer::public_transfer(ChimpanSui{
            id: object::new(ctx),
            name: name,
            description: launchpad.description,
            url: url,
            image_url: image_url,
        }, tx_context::sender(ctx));
        launchpad.minted = launchpad.minted + 1;
    }

    entry fun withdraw(launchpad: &mut LaunchpadData, ctx: &mut TxContext){
        let amount = balance::value(&launchpad.balance);
        transfer::public_transfer(coin::from_balance(balance::split(&mut launchpad.balance, amount), ctx), launchpad.fund_address);
    }

    entry fun update_launchpad_fund_address(_: &LaunchpadCap, launchpad: &mut LaunchpadData, fund_address: address){
        launchpad.fund_address = fund_address;
    }

    entry fun update_launchpad_price(_: &LaunchpadCap, launchpad: &mut LaunchpadData, price: u64){
        launchpad.price = price;
    }
}