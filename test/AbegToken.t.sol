// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2, stdJson} from "forge-std/Test.sol";

import {Merkle} from "../src/AbegToken.sol";

contract AbegTest is Test {
    using stdJson for string;
    Merkle public merkle;
    struct Result {
        bytes32 leaf;
        bytes32[] proof;
    }

    struct User {
        address user;
        uint id;
        uint amount;
    }
    Result public result;
    User public user;
    bytes32 root =
        0x8f7772450cbe800826816c4f9ef489cfca7f7d380e86a664c00b70456434a138;
    address user1 = 0x96902952Db10f7219aE23D56b3C09AdbD729A88e;

    function setUp() public {
        merkle = new Merkle(root);
        string memory _root = vm.projectRoot();
        string memory path = string.concat(_root, "/merkle_tree.json");

        string memory json = vm.readFile(path);
        string memory data = string.concat(_root, "/address_data.json");

        string memory dataJson = vm.readFile(data);

        bytes memory encodedResult = json.parseRaw(
            string.concat(".", vm.toString(user1))
        );
        user.user = vm.parseJsonAddress(
            dataJson,
            string.concat(".", vm.toString(user1), ".address")
        );
          user.id = vm.parseJsonUint(
            dataJson,
            string.concat(".", vm.toString(user1), ".tokenID")
        );
        user.amount = vm.parseJsonUint(
            dataJson,
            string.concat(".", vm.toString(user1), ".amount")
        );
        result = abi.decode(encodedResult, (Result));
        console2.logBytes32(result.leaf);
    }

    function testClaimed() public {
        bool success = merkle.claim(user.user, user.id, user.amount, result.proof);
        assertTrue(success);
    }

    function testAlreadyClaimed() public {
        merkle.claim(user.user, user.id, user.amount, result.proof);
        vm.expectRevert("already claimed");
        merkle.claim(user.user, user.id, user.amount, result.proof);
    }

    function testIncorrectProof() public {
        bytes32[] memory fakeProofleaveitleaveit;

        vm.expectRevert("not whitelisted");
        merkle.claim(user.user, user.id, user.amount, fakeProofleaveitleaveit);
    }
}
