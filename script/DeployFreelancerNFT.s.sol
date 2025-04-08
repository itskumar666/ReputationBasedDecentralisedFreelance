// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol"; // ✅ Correct path for forge-std
import "../src/FreelancerNFT.sol";

contract DeployFreelancerNFT is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY"); // Use your private key from .env

        vm.startBroadcast(deployerPrivateKey); // Safer than default signer
        FreelancerNFT nft = new FreelancerNFT();
        vm.stopBroadcast();

        console2.log("FreelancerNFT deployed at:", address(nft)); // ✅ Use console2 for logging
    }
}
