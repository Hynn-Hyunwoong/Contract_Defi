// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.9;

// import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
// import "./AirDrop.sol";

// contract GovernanceToken is ERC20 {
//     Airdrop public airdrop;
//     address public factory; 

//     modifier onlyFactory() {
//         require(msg.sender == factory, "Only factory can call this function.");
//         _;
//     }
//     constructor() ERC20("GovernanceToken", "GT") {
//         _mint(msg.sender, 1000);
//         airdrop = new Airdrop(address(this));
//     }

//     function mint(address to, uint amount) external onlyFactory{
//         _mint(to, amount);
//     }

//     function burn(address from, uint amount) external onlyFactory{
//         _burn(from, amount);

//     }
//     function distributeAirdrop(address[] memory recipients, uint256[] memory amounts) external {
//         airdrop.airdrop(recipients, amounts);
//     }
// }

// contract Token is ERC20 {

//     address public factory; 

//     modifier onlyFactory() {
//         require(msg.sender == factory, "Only factory can call this function.");
//         _;
//     }
//     constructor() ERC20("Token", "TKN") {}

//     function mint(address to, uint amount) external onlyFactory{
//         _mint(to, amount);
//     }

//     function burn(address from, uint amount) external onlyFactory{
//         _burn(from, amount);
//     }
// }

// contract Governance {
//     GovernanceToken public governanceToken;
//     Token public token;
//     mapping(uint => Topic) public topics;
//     mapping(address => uint) public lastVotedTime;
//     mapping(address => address) public delegates;
    
//     uint public nextTopicId;
//     uint public quorum = 51;
//     uint public Timelock = 2 weeks;

//     enum TopicType { MintToken, BurnToken, MintGovernanceToken, BurnGovernanceToken }

//     modifier onlyTokenHolders(){
//         require(governanceToken.balanceOf(msg.sender) > 0, "This function requires at least 1 governance token.");
//         _;
//     }

//     struct Topic {
//         TopicType topicType;
//         address target;
//         uint amount;
//         address proposer;
//         uint forVotes;
//         uint againstVotes;
//         bool executed;
//     }

//     event TopicProposed(uint id, TopicType topicType, address target, uint amount, address proposer);
//     event Voted(uint id, address voter, bool vote, uint weight);

//     constructor(address _governanceToken, address _token) {
//         governanceToken = GovernanceToken(_governanceToken);
//         token = Token(_token);
//     }

//     function proposeTopic(TopicType topicType, address target, uint amount) external {
//         require(governanceToken.balanceOf(msg.sender) >= 1, "This function requires at least 1 governance token.");
//         governanceToken.burn(msg.sender, 1);

//         topics[nextTopicId] = Topic(topicType, target, amount, msg.sender, 0, 0, false);
//         emit TopicProposed(nextTopicId, topicType, target, amount, msg.sender);
//         nextTopicId++;
//     }

//     function vote(uint topicId, bool voteValue) external {
//     require(lastVotedTime[msg.sender] + Timelock < block.timestamp, "You must wait for the timelock to expire before voting again.");
//     require(governanceToken.balanceOf(msg.sender) > 0, "This function requires at least 1 governance token.");
    
//     lastVotedTime[msg.sender] = block.timestamp;

//     uint weight = governanceToken.balanceOf(msg.sender);
//     Topic storage topic = topics[topicId];

//     if(delegates[msg.sender] != address(0)){
//         weight += governanceToken.balanceOf(delegates[msg.sender]);
//     }

//     if (voteValue) {
//         topic.forVotes += weight;
//     } else {
//         topic.againstVotes += weight;
//     }

//     emit Voted(topicId, msg.sender, voteValue, weight);
// }


//     function executeTopic(uint topicId) external onlyTokenHolders {
//         Topic storage topic = topics[topicId];

//         require(!topic.executed, "This topic has already been executed.");
//         require((topic.forVotes * 100) / (topic.forVotes + topic.againstVotes) >= quorum, "This topic has not been approved.");
//         require(topic.forVotes > (topic.forVotes + topic.againstVotes) / 2, "This topic has not been approved.");

//         topic.executed = true;

//         if (topic.topicType == TopicType.MintToken) {
//             token.mint(topic.target, topic.amount);
//         } else if (topic.topicType == TopicType.BurnToken) {
//             token.burn(topic.target, topic.amount);
//         } else if (topic.topicType == TopicType.MintGovernanceToken) {
//             governanceToken.mint(topic.target, topic.amount);
//         } else if (topic.topicType == TopicType.BurnGovernanceToken) {
//             governanceToken.burn(topic.target, topic.amount);
//         }
//     }

//     function delegate(address delegatee) external onlyTokenHolders {
//         delegates[msg.sender] = delegatee;
//     }
// }
