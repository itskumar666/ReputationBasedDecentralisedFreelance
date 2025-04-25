// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "./FreelancerNFT.sol";
contract EscrowWithNFT {
    enum Status {
        NotStarted,
        Funded,
        InProgress,
        Completed,
        Cancelled,
        Disputed
    }

    struct Milestone {
        uint256 amount;
        bool released;
    }

    struct Job {
        address client;
        uint256 freelancerNFTId;
        address nftContract; //minted NFT contract address(freelancerNFT)
        address arbiter;
        uint256 deadline;
        uint256 totalAmount;
        Status status;
        Milestone[] milestones;
    }
    struct Vote {
        address voter;
        bool voteForFreelancer;
        uint256 jobId;
        uint256 stake;
    }
    struct Dispute {
        bool isOpen;
        uint256 freelancerVoteCount;
        uint256 companyVoteCount;
        uint256 endTime;
        mapping(address => Vote) votes;
    }
    mapping(uint256 => Dispute) public disputes;

    uint256 public jobCounter;
    mapping(uint256 => Job) public jobs;

    event JobCreated(
        uint256 indexed jobId,
        address indexed client,
        uint256 totalAmount,
        uint256 deadline
    );
    event JobAccepted(uint256 indexed jobId, uint256 indexed nftId);
    event MilestoneReleased(uint256 indexed jobId, uint256 milestoneIndex);
    event JobCompleted(uint256 indexed jobId);
    event JobCancelled(uint256 indexed jobId);
    event DisputeRaised(uint256 indexed jobId);
    event DisputeResolved(uint256 indexed jobId, address winner);

    modifier onlyClient(uint256 jobId) {
        require(msg.sender == jobs[jobId].client, "Not the client");
        _;
    }

    modifier onlyFreelancer(uint256 jobId) {
        Job storage job = jobs[jobId];
        IERC721 nft = IERC721(job.nftContract);
        require(
            nft.ownerOf(job.freelancerNFTId) == msg.sender,
            "Not the NFT owner"
        );
        _;
    }

    modifier onlyArbiter(uint256 jobId) {
        require(msg.sender == jobs[jobId].arbiter, "Not the arbiter");
        _;
    }

    function createJob(
        address _arbiter,
        uint256 _deadline,
        uint256[] memory milestoneAmounts,
        address _nftContract
    ) external payable returns (uint256) {
        require(milestoneAmounts.length > 0, "Milestones required");

        uint256 total = 0;
        for (uint256 i = 0; i < milestoneAmounts.length; i++) {
            total += milestoneAmounts[i];
        }

        require(msg.value == total, "Incorrect value");

        Job storage job = jobs[jobCounter];
        job.client = msg.sender;
        job.arbiter = _arbiter;
        job.deadline = block.timestamp + _deadline;
        job.status = Status.Funded;
        job.nftContract = _nftContract;
        job.totalAmount = total;

        for (uint256 i = 0; i < milestoneAmounts.length; i++) {
            job.milestones.push(Milestone(milestoneAmounts[i], false));
        }

        emit JobCreated(jobCounter, msg.sender, msg.value, job.deadline);
        return jobCounter++;
    }

    function getMilestone(
        uint256 jobId,
        uint256 index
    ) external view returns (uint256 amount, bool released) {
        Milestone storage m = jobs[jobId].milestones[index];
        return (m.amount, m.released);
    }

    function getMilestoneCount(uint256 jobId) external view returns (uint256) {
        return jobs[jobId].milestones.length;
    }

    function acceptJob(uint256 jobId, uint256 nftId) external {
        Job storage job = jobs[jobId];
        require(job.status == Status.Funded, "Job not available");
        require(block.timestamp < job.deadline, "Job expired");

        IERC721 nft = IERC721(job.nftContract);
        require(nft.ownerOf(nftId) == msg.sender, "Not NFT owner");

        job.freelancerNFTId = nftId;
        job.status = Status.InProgress;

        emit JobAccepted(jobId, nftId);
    }

    function releaseMilestone(
        uint256 jobId,
        uint256 index
    ) external onlyClient(jobId) {
        Job storage job = jobs[jobId];
        require(index < job.milestones.length, "Invalid milestone");
        Milestone storage ms = job.milestones[index];
        require(!ms.released, "Already released");

        ms.released = true;
        address payable freelancer = payable(
            IERC721(job.nftContract).ownerOf(job.freelancerNFTId)
        );
        freelancer.transfer(ms.amount);

        emit MilestoneReleased(jobId, index);
    }

    function completeJob(uint256 jobId) external onlyClient(jobId) {
        Job storage job = jobs[jobId];
        require(job.status == Status.InProgress, "Not in progress");
        job.status = Status.Completed;
        emit JobCompleted(jobId);
    }

    function cancelJob(uint256 jobId) external onlyClient(jobId) {
        Job storage job = jobs[jobId];
        require(job.status == Status.Funded, "Cannot cancel");

        job.status = Status.Cancelled;
        payable(job.client).transfer(job.totalAmount);
        emit JobCancelled(jobId);
    }

    function raiseDispute(uint256 jobId) external {
        Job storage job = jobs[jobId];
        require(
            msg.sender == job.client ||
                msg.sender ==
                IERC721(job.nftContract).ownerOf(job.freelancerNFTId),
            "Unauthorized"
        );
        job.status = Status.Disputed;
        emit DisputeRaised(jobId);
    }
    function voteOnDispute(uint256 jobId, bool voteForFreelancer) public {
        Job storage job = jobs[jobId];
        require(job.status == Status.Disputed, "Not disputed");
        Dispute storage dispute = disputes[jobId];
        require(dispute.isOpen, "Vote is closed");
        require(dispute.votes[msg.sender].stake == 0, "Already voted"); // assuming stake > 0 means voted
    }
    function resolveDispute(
        uint256 jobId,
        address winner
    ) external onlyArbiter(jobId) {
        Job storage job = jobs[jobId];
        require(job.status == Status.Disputed, "Not disputed");

        uint256 unreleased = 0;
        for (uint256 i = 0; i < job.milestones.length; i++) {
            if (!job.milestones[i].released) {
                unreleased += job.milestones[i].amount;
                job.milestones[i].released = true;
            }
        }

        payable(winner).transfer(unreleased);
        job.status = Status.Completed;

        emit DisputeResolved(jobId, winner);
    }

    function refundIfExpired(uint256 jobId) external {
        Job storage job = jobs[jobId];
        require(block.timestamp > job.deadline, "Not expired");
        require(job.status == Status.Funded, "Invalid status");

        uint256 refundAmount = 0;
        for (uint256 i = 0; i < job.milestones.length; i++) {
            if (!job.milestones[i].released) {
                refundAmount += job.milestones[i].amount;
                job.milestones[i].released = true; // mark as released
            }
        }

        job.status = Status.Cancelled;
        payable(job.client).transfer(refundAmount);
    }
}
