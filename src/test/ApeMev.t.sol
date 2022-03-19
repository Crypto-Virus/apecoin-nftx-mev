// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

import { BaseTest, console } from "./base/BaseTest.sol";

import "../ApeMev.sol";

contract ApeMevTest is BaseTest {

    function setUp() public {
        vm.label(0xEA47B64e1BFCCb773A0420247C0aa0a3C1D2E5C5, "BAYC_NFTX_VAULT");
    }

    function test_ApeMev() public {
        console.log("Create ApeMev contract");
        ApeMev apeMev = new ApeMev();
        console.log("Finished creating ApeMev contract");

        vm.deal(address(apeMev), 1000 ether);


        apeMev.start();


    }
}
