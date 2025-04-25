// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract FreelancerNFT is ERC721URIStorage, Ownable {
    uint256 public tokenCounter;

    enum UserType  {
        Freelancer,
        Company
    }

    struct UserInfo {
        address userAddress;
        UserType userType;
        string metadataURI; // IPFS URI
    }

    mapping(uint256 => UserInfo) public users;

    event NFTMinted(
        address indexed user,
        uint256 indexed tokenId,
        UserType userType
    );

    constructor() ERC721("FreelancerPlatformNFT", "FPNFT") Ownable(msg.sender) {
        tokenCounter = 1;
    }

    modifier onlyTokenOwner(uint256 tokenId) {
        require(ownerOf(tokenId) == msg.sender, "Not token owner");
        _;
    }
    function updateMetadataURI(
        uint256 tokenId,
        string memory newURI
    ) external onlyTokenOwner(tokenId) {
        _setTokenURI(tokenId, newURI);
        users[tokenId].metadataURI = newURI;
    }

    mapping(address => bool) public hasMinted;

    function mintUserNFT(
        UserType _userType,
        string memory _tokenURI
    ) public returns (uint256) {
        require(!hasMinted[msg.sender], "User already minted an NFT");

        uint256 tokenId = tokenCounter;
        _safeMint(msg.sender, tokenId);
        _setTokenURI(tokenId, _tokenURI);

        users[tokenId] = UserInfo(msg.sender, _userType, _tokenURI);
        hasMinted[msg.sender] = true;

        emit NFTMinted(msg.sender, tokenId, _userType);
        tokenCounter++;
        return tokenId;
    }
    // function tokensOfOwner(
    //     address user
    // ) external view returns (uint256[] memory) {
    //     uint256 total = tokenCounter - 1;
    //     uint256 count = 0;

    //     for (uint256 i = 1; i <= total; i++) {
    //         if (ownerOf(i) == user) count++;
    //     }

    //     uint256[] memory result = new uint256[](count);
    //     uint256 index = 0;

    //     for (uint256 i = 1; i <= total; i++) {
    //         if (ownerOf(i) == user) {
    //             result[index] = i;
    //             index++;
    //         }
    //     }

    //     return result;
    // }

    function getUserInfo(
        uint256 tokenId
    ) external view returns (UserInfo memory) {
        require(ownerOf(tokenId) != address(0), "Token does not exist");
        return users[tokenId];
    }

    function revokeNFT(uint256 tokenId) external onlyOwner {
        _burn(tokenId);
        delete users[tokenId];
    }
    
}
