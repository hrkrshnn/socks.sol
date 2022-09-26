// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.17;

import "src/Socks.sol";
import "forge-std/Test.sol";

address constant minter = address(0xdead);

contract SocksTest is Test {
    Socks socks;

    function setUp() public {
        socks = new Socks();
    }

    function testName() public {
        assertEq(socks.name(), unicode"🧦.sol");
    }

    function testMintLeft() public {
        // Foundry testing env sets difficulty to 0 by default
        assertEq(block.difficulty, 0);

        assertEq(socks.balanceOf(minter, 0), 0);
        vm.prank(minter);
        socks.mint();
        assertEq(socks.balanceOf(minter, 0), 1);
        assertEq(socks.balanceOf(minter, 1), 0);
    }

    function testMintRight() public {
        vm.difficulty(type(uint256).max);
        assertEq(block.difficulty, type(uint256).max);

        assertEq(socks.balanceOf(minter, 1), 0);
        vm.prank(minter);
        socks.mint();
        assertEq(socks.balanceOf(minter, 1), 1);
        assertEq(socks.balanceOf(minter, 0), 0);
    }

    function testEndTime() public {
        assertEq(socks.endTime(), block.timestamp + 4 weeks);
    }

    function testMintFinished() public {
        vm.warp(socks.endTime() + 1);
        vm.expectRevert(MintFinished.selector);
        vm.prank(minter);
        socks.mint();
    }

    function testUriDifferent() public view {
        assert(keccak256(bytes(socks.uri(0))) != keccak256(bytes(socks.uri(1))));
    }

    function testTransfer() public {
        testMintLeft();
        address bob = address(0xdeaddead);

        assertEq(socks.balanceOf(minter, 0), 1);
        vm.prank(minter);
        socks.safeTransferFrom(minter, bob, 0, 1, "");
        assertEq(socks.balanceOf(minter, 0), 0);
        assertEq(socks.balanceOf(bob, 0), 1);
    }

    function testUriRevert() public {
        vm.expectRevert();
        socks.uri(2);
    }
}
