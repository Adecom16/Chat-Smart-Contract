// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ChatDapp {
    struct Message {
        address sender;
        address receiver;
        string content;
        // uint256 timestamp;
        // bool isRead;
    }

    mapping(address => mapping(address => Message[])) private messages;
    mapping(address => mapping(address => uint256)) private unreadMessageCounts;

    event MessageSent(
        address indexed sender,
        address indexed receiver,
        string content
        // uint256 timestamp
    );
    event MessageRead(
        address indexed sender,
        address indexed receiver,
        uint256 messageIndex
    );

    function sendMessage(address _receiver, string calldata _content) external {
        require(_receiver != address(0), "Invalid receiver address");
        require(bytes(_content).length > 0, "Message content cannot be empty");

        messages[msg.sender][_receiver].push(
            Message(msg.sender, _receiver, _content)
        );
        unreadMessageCounts[_receiver][msg.sender]++;

        emit MessageSent(msg.sender, _receiver, _content);
    }

    function getMessages(address _sender, address _receiver)
        external
        view
        returns (Message[] memory)
    {
        return messages[_sender][_receiver];
    }


}