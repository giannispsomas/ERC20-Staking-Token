// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {StakingToken} from "../src/StakingToken.sol";
import {Script} from "forge-std/Script.sol";

contract DeployStakingToken is Script {
    uint8 public constant decimals = 18;
    uint256 public initialSupply = 1000000 * (10 ** uint256(decimals));

    function run() external returns(StakingToken) {
        vm.startBroadcast();
        StakingToken token = new StakingToken(initialSupply);
        vm.stopBroadcast();
        return token;
    }
}