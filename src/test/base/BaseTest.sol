// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.10;

import { DSTest } from "ds-test/test.sol";
import { Vm } from "forge-std/Vm.sol";

import { console } from "../utils/console.sol";


contract BaseTest is DSTest {
    Vm internal immutable vm = Vm(HEVM_ADDRESS);
}