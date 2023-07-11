// 2. Governance

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./GovernanceToken.sol";
import "./Airdrop.sol";



contract Governance {
    GovernanceToken public governanceToken;
    address public factory;
    uint public totalTokenBurned;
    uint public totalTokenMinted;
    uint public totalTokenMintedGovernance;
    uint public totalTokenBurnedGovernance;
    uint public nextTopicId;
    uint public nextVoteId;
    uint public nextTokenBurnedId;
    uint public nextTokenMintedId;
    uint public nextTokenMintedGovernanceId;
    uint public nextTokenBurnedGovernanceId;
    uint public nextVoteWeightIdTokenBurned;
    uint public nextVoteWeightIdTokenMinted;
    uint public nextVoteWeightIdTokenMintedGovernance;
    uint public nextVoteWeightIdTokenBurnedGovernance;
    
    mapping(uint => Topic) public topics;
    mapping(address => uint) public lastVotedTime;
    mapping(uint => Vote) public votes;
    mapping(address => Delegation) public delegations;
    mapping(address => TimeLock) public timeLocks;

    enum TopicType {MintToken, BurnToken, MintGovernanceToken, BurnGovernanceToke}

    modifier onlyTokenHolder(){
        require(governanceToken.balanceOf(msg.sender) > 0, "Alert : only token holder can call this function");
        _;
    }

    modifier onlyFactory(){
        require(msg.sender == factory, "Alert : only factory can call this function");
        _;
    }

    struct Topic {
        uint id;
        string title;
        string description;
        uint voteCount;
        address tokenContract;
        uint startTime;
        uint endTime;
        uint addmint;
        uint addburn;
        bool isEnded;
        bool isApproved;
        mapping(address => bool) isVoted;
        mapping(address => uint) voteWeight;
    }

    struct Vote {
        uint id;
        uint topicId;
        address voter;
        uint voteWeight;
        bool isVoted;
        bool isApproved;
    }

    struct Delegation {
        address delegatee;
        uint startTime;
        bool revoked;
    }

    struct TimeLock {
        uint unlockTime;
        uint amount;
    }

    event TopicCreated(uint id, string title, string description, uint startTime, uint endTime);
    event TopicEnded(uint id, uint voteCount, bool isApproved);
    event VoteCreated(uint id, uint topicId, address voter, uint voteWeight, bool isApproved);
    event DelegateCreated(uint id, address delegate, uint delegateWeight);
    
    constructor(address _governanceToken) {
        governanceToken = GovernanceToken(_governanceToken);
        factory = msg.sender;
        governanceToken.setFactory(address(this));
    }

    // 1
    function proposeTopic(string memory _title, string memory _description, address _tokenContract , uint _addmint, uint _addburn) external onlyTokenHolder {
        require(bytes(_title).length > 0, "Topic title cannot be empty.");
        require(bytes(_description).length > 0, "Topic description cannot be empty.");
        require(governanceToken.balanceOf(msg.sender) > 0, "You must hold tokens to propose a topic.");
        require(block.timestamp > lastVotedTime[msg.sender] + 1 days, "You must wait 24 hours before proposing a new topic.");
        require(!(_addmint > 0 && _addburn > 0), "You can only add mint or burn, not both.");

        Topic storage newTopic = topics[nextTopicId];
        newTopic.id = nextTopicId;
        newTopic.title = _title;
        newTopic.description = _description;
        newTopic.tokenContract = _tokenContract;
        newTopic.addmint = _addmint;
        newTopic.addburn = _addburn;
        newTopic.startTime = block.timestamp;
        newTopic.endTime = block.timestamp + 2 days;
        newTopic.isEnded = false;
        newTopic.isApproved = false;

        emit TopicCreated(nextTopicId, _title, _description, block.timestamp, block.timestamp + 2 days);
        nextTopicId++;
        }

    // 2
    function vote(uint _topicId, bool _vote) external onlyTokenHolder {
    require(_topicId < nextTopicId, "Topic does not exist.");
    require(!topics[_topicId].isEnded, "Voting has ended.");
    require(!topics[_topicId].isVoted[msg.sender], "You have already voted for this topic.");
    require(block.timestamp > topics[_topicId].startTime, "Voting has not started yet.");

    uint voteWeight = governanceToken.balanceOf(msg.sender);

    Vote storage newVote = votes[nextVoteId];
    newVote.id = nextVoteId;
    newVote.topicId = _topicId;
    newVote.voter = msg.sender;
    newVote.voteWeight = voteWeight;
    newVote.isVoted = true;
    newVote.isApproved = _vote;

    emit VoteCreated(nextVoteId, _topicId, msg.sender, voteWeight, _vote);

    nextVoteId++;

    topics[_topicId].isVoted[msg.sender] = true;
    topics[_topicId].voteCount++;

    if(_vote){
        topics[_topicId].voteWeight[msg.sender] += voteWeight;
    } else {
        topics[_topicId].voteWeight[msg.sender] -= voteWeight;
    }
}


    function endTopic (uint _topicId) external onlyFactory{
        require(_topicId < nextTopicId, "Topic does not exist.");
        require(!topics[_topicId].isEnded, "Voting has ended.");
        require(block.timestamp > topics[_topicId].endTime, "Voting has not ended yet.");

        Topic storage topic = topics[_topicId];
        uint totalVotes = 0;
        for(uint i=0; i< nextVoteId; i++){
            if(votes[i].topicId == _topicId){
                totalVotes += votes[i].voteWeight;
            }
        }
        uint totalSupply = governanceToken.totalSupply();

        if(totalVotes * 2 < totalSupply) {
            topic.isApproved = false;
        } else {
            uint agreeVotes = 0;
            for(uint i=0; i <nextVoteId; i++){
                if(votes[i].topicId == _topicId && votes[i].isApproved){
                    agreeVotes += votes[i].voteWeight;
                } 
            }
            if(agreeVotes * 2 < totalVotes) {
                topic.isApproved = true;
                executeTopic(_topicId);
            } else {
                topic.isApproved = false;
            }
        }
        topic.isEnded = true;
        emit TopicEnded(_topicId, topic.voteCount, topic.isApproved);
    }

    function executeTopic(uint _topicId)internal onlyFactory{
    require(_topicId < nextTopicId, "Topic does not exist.");
    require(topics[_topicId].isEnded, "Voting has not ended yet.");
    require(topics[_topicId].isApproved, "Topic is not approved.");

    Topic storage topic = topics[_topicId];

    GovernanceToken token = GovernanceToken(topic.tokenContract);

    if(topic.addmint != 0) {
        token.mint(address(this), topic.addmint);
        totalTokenMinted += topic.addmint;
        totalTokenMintedGovernance += topic.addmint;
        nextTokenMintedId++;
        nextTokenMintedGovernanceId++;
        nextVoteWeightIdTokenMinted++;
        nextVoteWeightIdTokenMintedGovernance++;
    }

    if(topic.addburn != 0){
        token.burn(address(this), topic.addburn);
        totalTokenBurned += topic.addburn;
        totalTokenBurnedGovernance += topic.addburn;
        nextTokenBurnedId++;
        nextTokenBurnedGovernanceId++;
        nextVoteWeightIdTokenBurned++;
        nextVoteWeightIdTokenBurnedGovernance++;
    }
    }

    function delegateTokens(address delegatee) external onlyFactory {
        require(governanceToken.balanceOf(delegatee) > 0, "Delegatee must hold tokens.");
        require(delegations[msg.sender].delegatee == address(0) || delegations[msg.sender].revoked, "You have already delegated.");

        delegations[msg.sender].delegatee = delegatee;
        delegations[msg.sender].startTime = block.timestamp;
        delegations[msg.sender].revoked = false;

        _lockTokens(msg.sender, governanceToken.balanceOf(msg.sender), 48 hours);
    }

    function undelegateTokens() external  onlyFactory{
        require(!delegations[msg.sender].revoked, "You have not delegated.");
        require(block.timestamp > delegations[msg.sender].startTime + 48 hours, "You cannot undelegate within 48 hours of delegation.");

        delegations[msg.sender].revoked = true;
    }

    function stakeToken(uint _amount) external onlyFactory {
        require(_amount > 0, "amount cannot be 0");
        governanceToken.transferFrom(msg.sender, address(this), _amount);
        // staking Logic
    }

    function _lockTokens(address _account, uint256 _amount, uint256 _duration) internal onlyFactory {
        timeLocks[_account] = TimeLock(block.timestamp + _duration, _amount);
    }
}

