// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {LibNSErrors, LibNSEvents} from "./libraries/LibNameService.sol";

contract NameService {
    struct DomainDetails {
        string domainName;
        string avatarURI;
        address owner;
    }

    mapping(string => address) public nameToAddress;
    mapping(string => DomainDetails) public domains;

    function getDomainDetails(
        string memory _domainName
    ) public view returns (string memory, string memory, address) {
        if (nameToAddress[_domainName] == address(0)) {
            revert LibNSErrors.DomainNotRegistered();
        }

        return (
            domains[_domainName].domainName,
            domains[_domainName].avatarURI,
            domains[_domainName].owner
        );
    }

    function registerNameService(
        string memory _domainName,
        string memory _avatarURI
    ) public {
        if (nameToAddress[_domainName] != address(0)) {
            revert LibNSErrors.NameAlreadyTaken();
        }
        nameToAddress[_domainName] = msg.sender;
        domains[_domainName] = DomainDetails(
            _domainName,
            _avatarURI,
            msg.sender
        );

        emit LibNSEvents.NameRegistered(msg.sender, _domainName);
    }

    function updateDomainAvatar(
        string memory _domainName,
        string memory _avatarURI
    ) public {
        if (nameToAddress[_domainName] == address(0)) {
            revert LibNSErrors.DomainNotRegistered();
        }
        if (nameToAddress[_domainName] != msg.sender) {
            revert LibNSErrors.NotDomainOwner();
        }

        domains[_domainName].avatarURI = _avatarURI;
        emit LibNSEvents.AvatarUpdated(msg.sender, _domainName);
    }
}