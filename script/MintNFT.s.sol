// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "forge-std/Script.sol";
import "../src/FreelancerNFT.sol";

contract MintNFT is Script {
    function run(string memory _userType) external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address nftContractAddress = vm.envAddress("NFT_CONTRACT"); // read from .env or hardcode

        string memory metadataURI = "ipfs://QmXYZ123..."; // replace with actual IPFS hash

        FreelancerNFT.UserType userType;

        if (keccak256(abi.encodePacked(_userType)) == keccak256("freelancer")) {
            userType = FreelancerNFT.UserType.Freelancer;
        } else {
            userType = FreelancerNFT.UserType.Company;
        }

        vm.startBroadcast(deployerPrivateKey);

        FreelancerNFT nft = FreelancerNFT(nftContractAddress);
        nft.mintUserNFT(userType, metadataURI);

        vm.stopBroadcast();
    }
}
