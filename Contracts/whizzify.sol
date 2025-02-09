// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// Reward Distribution Contract
contract WhizzifyRewards is Ownable, ReentrancyGuard {
    IERC20 public rewardToken; // ERC20 token for rewards
    mapping(address => uint256) public rewards;
    event RewardAdded(address indexed participant, uint256 amount);
    event RewardClaimed(address indexed participant, uint256 amount);

    constructor(address _rewardToken) {
        rewardToken = IERC20(_rewardToken);
    }

    function addReward(address participant, uint256 amount) external onlyOwner {
        rewards[participant] += amount;
        emit RewardAdded(participant, amount);
    }

    function claimReward() external nonReentrant {
        uint256 amount = rewards[msg.sender];
        require(amount > 0, "No rewards available");
        rewards[msg.sender] = 0;
        require(rewardToken.transfer(msg.sender, amount), "Transfer failed");
        emit RewardClaimed(msg.sender, amount);
    }
}

// Quiz Management Contract
contract WhizzifyQuiz is Ownable {
    struct Quiz {
        string question;
        string correctAnswer;
        bool active;
    }
    mapping(uint256 => Quiz) public quizzes;
    mapping(address => mapping(uint256 => bool)) public hasAttempted;
    event QuizCreated(uint256 quizId, string question);
    event QuizAnswered(address participant, uint256 quizId, bool correct);

    function createQuiz(uint256 quizId, string memory question, string memory correctAnswer) external onlyOwner {
        quizzes[quizId] = Quiz(question, correctAnswer, true);
        emit QuizCreated(quizId, question);
    }

    function answerQuiz(uint256 quizId, string memory answer) external {
        require(quizzes[quizId].active, "Quiz not active");
        require(!hasAttempted[msg.sender][quizId], "Already attempted");
        hasAttempted[msg.sender][quizId] = true;
        bool correct = keccak256(abi.encodePacked(answer)) == keccak256(abi.encodePacked(quizzes[quizId].correctAnswer));
        emit QuizAnswered(msg.sender, quizId, correct);
    }
}

// Fund Management Contract
contract WhizzifyFund is Ownable {
    mapping(address => uint256) public deposits;
    event FundsDeposited(address indexed organization, uint256 amount);
    event FundsWithdrawn(address indexed organization, uint256 amount);

    function depositFunds() external payable {
        require(msg.value > 0, "Must deposit some funds");
        deposits[msg.sender] += msg.value;
        emit FundsDeposited(msg.sender, msg.value);
    }

    function withdrawFunds(uint256 amount) external {
        require(deposits[msg.sender] >= amount, "Insufficient balance");
        deposits[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
        emit FundsWithdrawn(msg.sender, amount);
    }
}

// Admin & Security Contract
contract WhizzifyAdmin is Ownable {
    bool public paused;
    event Paused();
    event Unpaused();

    modifier whenNotPaused() {
        require(!paused, "Contract is paused");
        _;
    }

    function pause() external onlyOwner {
        paused = true;
        emit Paused();
    }

    function unpause() external onlyOwner {
        paused = false;
        emit Unpaused();
    }
}

// Upgradeability Proxy Contract (Optional)
import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

