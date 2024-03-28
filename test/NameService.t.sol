// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {NameService} from "../src/NameService.sol";

import {LibNSErrors, LibNSEvents} from "../src/libraries/LibNameService.sol";

contract NameServiceTest is Test {
    NameService nameServiceContract;
    address contractAddress;

    address A = address(0xa);
    address B = address(0xb);
    address C = address(0xc);

    event ContractDeployed(address indexed contractAddress);

    function setUp() public {
        nameServiceContract = new NameService();
        contractAddress = address(nameServiceContract);
        emit ContractDeployed(contractAddress);

        A = mkaddr("user A");
        B = mkaddr("user B");
        C = mkaddr("user C");
    }

    function testRegisterNameService() public {
        switchSigner(A);

        nameServiceContract.registerNameService("test", "test");
        assert(nameServiceContract.nameToAddress("test") != address(0));

        (string memory _domainName, , address _owner) = nameServiceContract
            .getDomainDetails("test");
        assert(
            keccak256(abi.encodePacked(_domainName)) ==
                keccak256(abi.encodePacked("test"))
        );
        assert(_owner == A);
    }
    function testRegisterNameServiceEmitEvent() public {
        switchSigner(A);

        // assert event emitted
        vm.expectEmit(true, true, false, false);
        emit LibNSEvents.NameRegistered(A, "test");
        emit LibNSEvents.AvatarUpdated(A, "test");
        nameServiceContract.registerNameService("test", "test");
    }

    function testRegisterNameTwiceRevert() public {
        switchSigner(A);

        nameServiceContract.registerNameService("test", "test");

        switchSigner(B);
        // assert revert
        vm.expectRevert(
            abi.encodeWithSelector(LibNSErrors.NameAlreadyTaken.selector)
        );
        nameServiceContract.registerNameService("test", "avatarTest");
    }

    function testGetDomainDetails() public {
        switchSigner(A);
        nameServiceContract.registerNameService("test", "test");

        (
            string memory _domainName,
            string memory _avatarURI,
            address _owner
        ) = nameServiceContract.getDomainDetails("test");

        assert(
            keccak256(abi.encodePacked(_domainName)) ==
                keccak256(abi.encodePacked("test"))
        );
        assert(
            keccak256(abi.encodePacked(_avatarURI)) ==
                keccak256(abi.encodePacked("test"))
        );
        assert(_owner == A);
    }

    function testGetDomainDetailsFailForUnregisteredDomains() public {
        vm.expectRevert(
            abi.encodeWithSelector(LibNSErrors.DomainNotRegistered.selector)
        );
        nameServiceContract.getDomainDetails("test");
    }

    function testUpdateAvatarURI() public {
        switchSigner(A);
        nameServiceContract.registerNameService("test", "test");

        nameServiceContract.updateDomainAvatar("test", "ipfs://newAvatar.jpg");

        (, string memory _avatarURI, ) = nameServiceContract.getDomainDetails(
            "test"
        );

        assert(
            keccak256(abi.encodePacked(_avatarURI)) ==
                keccak256(abi.encodePacked("ipfs://newAvatar.jpg"))
        );
    }
    function testUpdateAvatarURIFailWhenCalledForDomainNotOwned() public {
        nameServiceContract.registerNameService("test", "test");

        switchSigner(A);

        vm.expectRevert(
            abi.encodeWithSelector(LibNSErrors.NotDomainOwner.selector)
        );
        nameServiceContract.updateDomainAvatar("test", "ipfs://newAvatar.jpg");
    }

    function testUpdateAvatarURIFailForUnregigsteredDomains() public {
        switchSigner(A);

        vm.expectRevert(
            abi.encodeWithSelector(LibNSErrors.DomainNotRegistered.selector)
        );
        nameServiceContract.updateDomainAvatar("test", "ipfs://newAvatar.jpg");
    }

    function switchSigner(address _newSigner) public {
        address foundrySigner = 0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38;
        if (msg.sender == foundrySigner) {
            vm.startPrank(_newSigner);
        } else {
            vm.stopPrank();
            vm.startPrank(_newSigner);
        }
    }

    function mkaddr(string memory name) public returns (address) {
        address addr = address(
            uint160(uint256(keccak256(abi.encodePacked(name))))
        );
        vm.label(addr, name);
        return addr;
    }
}