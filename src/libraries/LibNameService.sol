// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

library LibNSEvents {
    event NameRegistered(address indexed owner, string domainName);
    event AvatarUpdated(address indexed owner, string domainName);
}

library LibNSErrors {
    error NameAlreadyTaken();
    error DomainNotRegistered();
    error NotDomainOwner();
}