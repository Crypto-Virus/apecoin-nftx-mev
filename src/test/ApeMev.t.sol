// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

import { BaseTest, console } from "./base/BaseTest.sol";

import "../ApeMev.sol";

contract ApeMevTest is BaseTest {

    address private constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address private constant APECOIN = 0x4d224452801ACEd8B2F0aebE155379bb5D594381;
    address private constant BAYC_NFTX_VAULT = 0xEA47B64e1BFCCb773A0420247C0aa0a3C1D2E5C5;
    address private constant BAYC_ERC721 = 0xBC4CA0EdA7647A8aB7C2061c2E118A18a936f13D;
    address private constant AIRDROP = 0x025C6da5BD0e6A5dd1350fda9e3B6a614B205a1F;

    function setUp() public {
        vm.label(WETH, "WETH");
        vm.label(APECOIN, "APECOIN");
        vm.label(BAYC_NFTX_VAULT, "BAYC_NFTX_VAULT");
        vm.label(BAYC_ERC721, "BAYC_ERC721");
        vm.label(AIRDROP, "AIRDROP");
    }

    function test_ApeMev() public {
        // Create Contract that will execute MEV
        ApeMev apeMev = new ApeMev();

        // Give Contract 1000 ether
        vm.deal(address(apeMev), 1000 ether);

        // Start MEV
        apeMev.start();

        // Print Balances
        console.log("My balances after mev");
        console.log("ETH", address(this).balance);
        console.log("WETH", IERC20(WETH).balanceOf(address(this)));
        console.log("APECOIN", IERC20(APECOIN).balanceOf(address(this)));
        console.log("BAYC_NFTX_VAULT_ERC20", IERC20(BAYC_NFTX_VAULT).balanceOf(address(this)));


    }
}
