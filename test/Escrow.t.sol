// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import "../src/EscrowWithNFT.sol";

contract EscrowTest is Test {
    address public arbiter;
    address public nftContract;
    uint256 public deadline;
    uint256[] milestone;
    enum Status { NotStarted, Funded, InProgress, Completed, Cancelled, Disputed }


    EscrowWithNFT public escrow;

    struct Milestone {
        uint256 amount;
        bool released;
    }

   function setUp() public {
    arbiter = vm.envAddress("ARBITER_KEY");
    nftContract = vm.envAddress("NFT_CONTRACT");
    deadline = 1744224000;


    escrow = new EscrowWithNFT();
}

function testCreateJobSuccess() public {

    milestone.push(1);
    milestone.push(2);
    milestone.push(3);
    milestone.push(4);
    uint256 total = 0;
    for (uint8 i = 0; i < milestone.length; i++) {
        total += milestone[i];
    }

    uint256 escrowId = escrow.createJob{value: total}(arbiter, deadline, milestone, nftContract);
    
    ( , , address storedNftContract, address storedArbiter, uint256 storedDeadline, uint256 storedAmount, EscrowWithNFT.Status storedStatus) = escrow.jobs(escrowId);

    assertEq(storedNftContract, nftContract);
    assertEq(storedArbiter, arbiter);
    assertEq(storedDeadline, deadline + block.timestamp);
    assertEq(storedAmount, total);
    assertEq(uint(storedStatus), uint(EscrowWithNFT.Status.Funded));
}
function testCreateJobFailsWithoutMilestones()public {
    vm.expectRevert("Milestones required");
    uint256 escrowId=escrow.createJob{value:1}(arbiter,deadline,milestone,nftContract);
    escrow.getMilestoneCount(escrowId);  

}
function testAcceptJob()public{


    milestone.push(1);
    milestone.push(2);
    milestone.push(3);
    milestone.push(4);
    uint256 total = 0;
    for (uint8 i = 0; i < milestone.length; i++) {
        total += milestone[i];
    }

    uint256 escrowId = escrow.createJob{value: total}(arbiter, deadline, milestone, nftContract);
    
    ( , , address storedNftContract, address storedArbiter, uint256 storedDeadline, uint256 storedAmount, EscrowWithNFT.Status storedStatus) = escrow.jobs(escrowId);
    assertEq(storedNftContract, nftContract);
    assertEq(storedArbiter, arbiter);
    assertEq(storedDeadline, deadline + block.timestamp);
    assertEq(storedAmount, total);
    assertEq(uint(storedStatus), uint(EscrowWithNFT.Status.Funded));
       
}
function testAcceptJobFailsWithInvalidNFT()public{
   milestone.push(1);
   milestone.push(2);
   milestone.push(3);
   uint256 total=0;
   for(uint8 i=0;i<milestone.length;i++){
    total+=milestone[i];
   }
    uint256 escrowId = escrow.createJob{value: total}(arbiter, deadline, milestone, nftContract);
    console.log(nftContract);
    vm.expectRevert();
    escrow.acceptJob(escrowId, 1);
    
}
function testAcceptJobFailsWithInvalidJobId()public{
     milestone.push(1);
   milestone.push(2);
   milestone.push(3);
   uint256 total=0;
   for(uint8 i=0;i<milestone.length;i++){
    total+=milestone[i];
   }
    uint256 escrowId = escrow.createJob{value: total}(arbiter, deadline, milestone, nftContract);
    vm.expectRevert();
    escrow.acceptJob(escrowId, 1);

}
// function testAcceptJobFailsWithInvalidStatus()public{
//     milestone.push(1);
//    milestone.push(2);
//    milestone.push(3);
//    uint256 total=0;
//    for(uint8 i=0;i<milestone.length;i++){
//     total+=milestone[i];
//    }
//     uint256 escrowId = escrow.createJob{value: total}(arbiter, deadline, milestone, nftContract);
//     vm.expectRevert();
//     escrow.
    

// }
// function testAcceptJobFailsWithInvalidDeadline()public{
//     milestone.push(1);
//     milestone.push(2);
//     milestone.push(3);
//     uint256 total=0;
//     for(uint8 i=0;i<milestone.length;i++){
//      total+=milestone[i];
//     }
//     uint256 escrowId = escrow.createJob{value: total}(arbiter, deadline, milestone, nftContract);
//       vm.expectRevert();

      
      
// }





}
