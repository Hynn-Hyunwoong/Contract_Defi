//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract Timelock {
    using SafeMath for uint;

    address private admin;

    struct StableState {
        bool status;
        bool canceled;
        uint256 blockTime;
        bool close;
    }

    mapping(bytes32 => StableState) private proposals;

    uint public constant GRACE_PERIOD = 14 days;
    uint public constant MINIMUM_DELAY = 10;
    uint public constant MAXIMUM_DELAY = 30 days;

    uint delay;

    constructor(uint _delay, address _admin){
        require(_delay > MINIMUM_DELAY, "Timelock : Delay must be longer than 2 days.");
        require(_delay < MAXIMUM_DELAY, "Timelock : Delay must be less than 30 days.");

        admin = _admin;
        delay = _delay;
    }

    function setDelay (uint _delay)public {
        require(_delay > MINIMUM_DELAY, "Timelock : Delay must be longer than 2 days.");
        require(_delay < MAXIMUM_DELAY, "Timelock : Delay must be less than 30 days.");

        delay = _delay;
    }

    function queueTransaction (bytes memory _callFunction, uint256 _blockTime) public {
        bytes32 hashdata = keccak256(_callFunction);
        if(proposals[hashdata].blockTime == 0){
            proposals[hashdata] = StableState(false, false, _blockTime, false);
        }
    }

    function cancelTransaction (bytes memory _callFunction) public returns(bool){
        require(msg.sender == admin, "Timelock :  only owner");
        bytes32 hashdata = keccak256(_callFunction);
        proposals[hashdata].canceled = true;
        return true;
    }

    function executeTransaction(bytes memory _callFunction, uint256 etc) public returns(bool){
        require(msg.sender == admin,  "Timelock :  only owner");
        bytes32 hashdata = keccak256(_callFunction);
        require(etc > proposals[hashdata].blockTime.add(delay), "Timelock : no timing");
        proposals[hashdata].status = true;
        return true;
    }

    function getTransaction (bytes memory _callFunction) public view returns(StableState memory) {
        bytes32 hashdata = keccak256(_callFunction);
        return proposals[hashdata];
    }

    function getHash (bytes memory _callFunction) public pure returns(bytes32){
        return keccak256(_callFunction);
    }

    function closePropose(bytes memory funcName) public returns(bool) {
        proposals[keccak256(funcName)].close = true;
        return true;
    }
}



//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./SelfToken.sol";
import "./timelock.sol";
import "./Factory_v1.sol";

contract Governance {
    address private owner;
    address private govToken;
    uint256 private proposalAmount;
    address private goverAddress;
    address private timelock;
    address private factory;

    struct Receipt {
        bool vote;
        bool agree;
    }


    struct Proposal {
        address proposer;
        uint startBlock;
        uint endBlock;
        string callData;    // createPool, changeLevel
        bytes callFunction; // ex) createPool_ETH, changeLevel_ETH
        bool canceled;
        bool executed;
        uint256 amountVote;
        mapping(address => Receipt) hasVotes;
    }

    address[] public participants;

    mapping(uint => Proposal) private proposes;
    mapping(uint => address[]) private votes;

    constructor(address _owner) {
        owner = _owner;
        goverAddress = address(this);
    }


    function propose(address _proposer, string memory _callData, string memory _callFunction) public {
        require(
            SelfToken(govToken).balanceOf(_proposer) > 0,
            "Governance : Do not have a vASD token."
        );

        uint startBlock = block.number;
        uint endBlock = block.number + 17280;
        Proposal storage newProposal = proposes[proposalAmount + 1];
        newProposal.proposer = _proposer;
        newProposal.startBlock = startBlock;
        newProposal.endBlock = endBlock;
        newProposal.callFunction = bytes(_callFunction);
        newProposal.callData = _callData;
        newProposal.canceled = false;
        newProposal.executed = false;
        newProposal.amountVote = 0;
        // newProposal.hasVotes[_proposer] = Receipt(true, true);
        proposalAmount += 1;

        SelfToken(govToken)._burn(_proposer, 1); // burn 시킬 govtoken의 가치에 대해서 ?
    }

    function voting(address _participant, uint _proposal, bool _agree) public {
        require(
            SelfToken(govToken).balanceOf(_participant) > 0,
            "Governance : Do not have a vASD token."
        );
        require(
            proposes[_proposal].hasVotes[_participant].vote == false,
            "Governance : It is a proposal that has already been voted on."
        );
        // require(proposes[_proposal].endBlock > block.number, "Governance : It's an overdue vote.");
        proposes[_proposal].hasVotes[_participant] = Receipt(true, _agree);
        votes[_proposal].push(_participant);
        proposes[_proposal].amountVote +=
            uint256(SelfToken(govToken).balanceOf(_participant) * 10 ** 18)*100 /
            SelfToken(govToken).totalSupply();
    }

    function timelockExecute(uint _proposal) public returns (bool) {
        require(msg.sender == owner, "Governance : only owner");
        // require(proposes[_proposal].endBlock < block.number, "Governance : It hasn't been three days."); //3일 > 17,280
        if (proposes[_proposal].amountVote >= 51) {
            proposes[_proposal].executed = true;
            Timelock(timelock).queueTransaction(
                    proposes[_proposal].callFunction,
                    block.timestamp
                );
            return true;
            // calldata 짝수 자리 만들어주기. ex) 21자리면 22자리로 맞춰준다.
            // 아마 else문 안에 코드만 잇으면 될 것 임.
            // if (proposes[_proposal].callData.length % 2 != 0) {
            //     bytes memory paddedCallData = abi.encodePacked(
            //         proposes[_proposal].callData
            //     );
            //     proposes[_proposal].callData = paddedCallData;
            //     Timelock(timelock).queueTransaction(
            //         paddedCallData,
            //         block.timestamp
            //     );
            //     return true;
            // } else {
                // Timelock(timelock).queueTransaction(
                //     proposes[_proposal].callFunction,
                //     block.timestamp
                // );
                // return true;
            // }
        } else {
            proposes[_proposal].canceled = true;
            return false;
        }
        //작동 안됨. < 수정 후 반영
        /*
                    if (proposes[_proposal].callData.length % 2 != 0) {
            bytes memory paddedCallData = new bytes(proposes[_proposal].callData.length + 1);
            proposes[_proposal].callData = paddedCallData;
            paddedCallData[0] = 0;
            for (uint256 i = 0; i < proposes[_proposal].callData.length; i++) {
            paddedCallData[i + 1] = proposes[_proposal].callData[i];
            }
            Timelock(timelock).queueTransaction(paddedCallData, block.timestamp);
            return true;
            } else {
            Timelock(timelock).queueTransaction(proposes[_proposal].callData, block.timestamp);
            return true;
            }
        */
    }

    function proposalExecute(uint _proposal , uint256 etc) public returns (bool) {
        require(msg.sender == owner, "Governance : only owner");
        // require(proposes[_proposal].endBlock < block.number, "Governance : It hasn't been three days.");
        require(
            proposes[_proposal].executed,
            "Governance : It's a vote that didn't pass."
        );
        require(
            Timelock(timelock).executeTransaction(
                proposes[_proposal].callFunction,
                block.timestamp
            ),
            "Governance : Timelock is running."
        );
        require(
            Timelock(timelock)
                .getTransaction(proposes[_proposal].callFunction)
                .status                                 
        );
        //실행
        Timelock(timelock).executeTransaction(proposes[_proposal].callFunction, etc);
        return true;
    }

    function changeLevel(address _token, uint256 _level, uint256 _proposal) public returns(bool){
        // timeLock queue, time 비교
        // require(Timelock(timelock).getTransaction(bytes("changeLevel")).status);
        require(isStatus(proposes[_proposal].callFunction));
        require(!isClose(proposes[_proposal].callFunction), "Is Closed");
        Factory_v1(factory).poolLvup(_token, _level);
        Timelock(timelock).closePropose(proposes[_proposal].callFunction);
        return true;
        //factory 로 보내서 levelchange 시키는것, 의제에 의해서 실행될것.
        //factory 에 보내야할것 > ca랑 level 입력해서 보내주기 > callData
    }

    function createPool(address _differentToken, address _AsdToken, uint256 _proposal) public returns(bool){
        // require(Timelock(timelock).getTransaction(bytes("createPool")).status);
        // timeLock queue, time 비교
        require(isStatus(proposes[_proposal].callFunction));
        require(!isClose(proposes[_proposal].callFunction), "Is Closed");
        Factory_v1(factory).createPool(_differentToken, _AsdToken);
        Timelock(timelock).closePropose(proposes[_proposal].callFunction);
        return true;
    }

    function isStatus(bytes memory funcName) view public returns(bool){
        return Timelock(timelock).getTransaction(funcName).status;
    }
    function isClose(bytes memory funcName) view public returns(bool){
        return Timelock(timelock).getTransaction(funcName).close;
    }

    function changeOwner(address _newOwner) private {
        owner = _newOwner;
    }

    function setTokenAddress(address _token) public {
        require(owner == msg.sender);
        govToken = _token;
    }

    function setTimelockAddress(address _timelock) public {
        require(owner == msg.sender);
        timelock = _timelock;
    }

    function setFactoryAddress(address _factory) public {
        require(owner == msg.sender);
        factory = _factory;
    }

    function getProposal(
        uint _idx
    )
        public
        view
        returns (address, uint, uint, string memory, bytes memory, bool, bool, uint)
    {
        Proposal storage proposal = proposes[_idx];
        return (
            proposal.proposer,
            proposal.startBlock,
            proposal.endBlock,
            proposal.callData,
            proposal.callFunction,
            proposal.canceled,
            proposal.executed,
            proposal.amountVote
        );
    }

    function getCallData(uint _proposal) public view returns (string memory) {
        return proposes[_proposal].callData;
    }

    function getCallFunction(uint _proposal) public view returns(bytes memory) {
        return proposes[_proposal].callFunction;
    }
}