// pragma solidity 0.8.29;

// import "openzeppelin-contracts/token/ERC721/ERC721.sol";
// import "@openzeppelin/contracts/access/Ownable.sol";

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

abstract contract ReputationNFT is ERC721, Ownable {
    uint256 public tokenIdCounter;
    mapping(uint256 => uint256) public ratings; // Token ID to rating (0-100)

    constructor() ERC721("FreelancerReputation", "FREP") {}

    function mint(address to) external onlyOwner returns (uint256) {
        tokenIdCounter++;
        _safeMint(to, tokenIdCounter);
        return tokenIdCounter;
    }

    function updateRating(uint256 tokenId, uint256 rating) external {
        require(ownerOf(tokenId) == msg.sender, "Not owner");
        require(rating <= 100, "Invalid rating");
        ratings[tokenId] = rating;
    }

    //
}
