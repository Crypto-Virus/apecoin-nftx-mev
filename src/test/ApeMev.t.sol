// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

import { BaseTest, console } from "./base/BaseTest.sol";

import "../ApeMev.sol";

contract ApeMevTest is BaseTest {

    function setUp() public {
    }

    function test_ApeMev() public {
        console.log("Create ApeMev contract");
        ApeMev apeMev = new ApeMev();
        console.log("Finished creating ApeMev contract");

        console.log("giving eth");
        vm.deal(address(apeMev), 1 ether);
        vm.deal(msg.sender, 10 ether);

        console.log("balance", msg.sender.balance);
        console.log("balance mev", address(apeMev).balance);

        apeMev.start();


    }
}
