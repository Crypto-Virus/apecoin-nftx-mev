// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

import { BaseTest, console } from "./base/BaseTest.sol";

import "../ApeMev.sol";

contract ApeMevTest is BaseTest {

    address private constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address private constant APECOIN = 0x4d224452801ACEd8B2F0aebE155379bb5D594381;
    address private constant BAYC_NFTX_VAULT = 0xEA47B64e1BFCCb773A0420247C0aa0a3C1D2E5C5;
    address private constant BAYC_ERC721 = 0xBC4CA0EdA7647A8aB7C2061c2E118A18a936f13D;

    function setUp() public {
        vm.label(WETH, "WETH");
        vm.label(APECOIN, "APECOIN");
        vm.label(BAYC_NFTX_VAULT, "BAYC_NFTX_VAULT");
        vm.label(BAYC_ERC721, "BAYC_ERC721");
    }

    function test_ApeMev() public {
        console.log("Create ApeMev contract");
        ApeMev apeMev = new ApeMev();
        console.log("Finished creating ApeMev contract");

        vm.deal(address(apeMev), 1000 ether);


        apeMev.start();


    }
}
