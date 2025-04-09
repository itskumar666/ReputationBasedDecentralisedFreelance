//SPDX-License-Identifier:MIT
pragma solidity ^0.8.24;
import "../script/MintNFT.s.sol";
import "../script/DeployFreelancerNFT.s.sol";
import "../src/FreelancerNFT.sol";
import {Test,console} from "forge-std/Test.sol";
import {StdCheats} from "forge-std/StdCheats.sol";


contract FreelancerNFTTest is StdCheats,Test{
  FreelancerNFT public freelancerNFT;
  address temp1=makeAddr("temp1");
  uint256 public tokenCounter;
  function  setUp() external{
     freelancerNFT=new FreelancerNFT();
     
     tokenCounter=0;
     
  }
  function onERC721Received(
    address,
    address,
    uint256,
    bytes calldata
) external pure returns (bytes4) {
    return this.onERC721Received.selector;
}


   function testMintUserNFT()public{
      string memory uri = "ipfs://xyz123";
      uint tokenMintedId=freelancerNFT.mintUserNFT(FreelancerNFT.UserType.Freelancer, uri);
      (address userAddress, FreelancerNFT.UserType userType, string memory storedURI) = freelancerNFT.users(tokenMintedId);

      assertEq(userAddress, address(this));
      assertEq(uint8(userType),uint8(FreelancerNFT.UserType.Freelancer));
      assertEq(storedURI,uri);
      string memory returnedTokenUri=freelancerNFT.tokenURI(tokenMintedId);
      assertEq(returnedTokenUri,uri);

   }
   function testDuplicateMint()public{
       string memory uri = "ipfs://xyz123";
      freelancerNFT.mintUserNFT(FreelancerNFT.UserType.Freelancer, uri);
      
      vm.expectRevert("User already minted an NFT");
      freelancerNFT.mintUserNFT(FreelancerNFT.UserType.Freelancer, uri);

   }function testOnlyTokenOwner()public{
       string memory uri = "ipfs://xyz123";
      uint tokenMintedId=freelancerNFT.mintUserNFT(FreelancerNFT.UserType.Freelancer, uri);
      assertFalse(freelancerNFT.ownerOf(tokenMintedId) == temp1);
   }
   function testUpdateMetaDataUriCanBeUpdateByTokenOwnerOnly()public{

      string memory uri = "ipfs://xyz123";
      string memory NewURI = "ipfs://xyz123";

      uint tokenMintedId=freelancerNFT.mintUserNFT(FreelancerNFT.UserType.Freelancer, uri);
      vm.prank(temp1);
      vm.expectRevert( "Not token owner");
      freelancerNFT.updateMetadataURI(tokenMintedId, NewURI);

   }
   function testUpdateMetadataUri()public{
      string memory uri ="ipfs://xyz123";
      string memory NewURI = "ipfs://xyz123";

      uint tokenMintedId=freelancerNFT.mintUserNFT(FreelancerNFT.UserType.Freelancer, uri);
      freelancerNFT.updateMetadataURI(tokenMintedId, NewURI);

   }
   function testGetUserInfo()public{
      string memory uri ="ipfs://xyz123";
      uint id1=freelancerNFT.mintUserNFT(FreelancerNFT.UserType.Freelancer, uri);
      FreelancerNFT.UserInfo memory info = freelancerNFT.getUserInfo(id1);
      assertEq(info.userAddress,address(this));
      vm.prank(temp1);
      uint id2=freelancerNFT.mintUserNFT(FreelancerNFT.UserType.Freelancer, uri);
      FreelancerNFT.UserInfo memory info1 = freelancerNFT.getUserInfo(id2);
            assertEq(info1.userAddress,temp1);
      
   }

  function testRevokeNFT() public {
    string memory uri = "ipfs://xyz123";
    uint id1 = freelancerNFT.mintUserNFT(FreelancerNFT.UserType.Freelancer, uri);
    freelancerNFT.revokeNFT(id1);

    vm.expectRevert(abi.encodeWithSignature("ERC721NonexistentToken(uint256)", id1));
    freelancerNFT.getUserInfo(id1);
}






}

