// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import {IERC721Receiver} from "openzeppelin/token/ERC721/IERC721Receiver.sol";
import {IERC721} from "openzeppelin/token/ERC721/IERC721.sol";
import {ERC20} from "openzeppelin/token/ERC20/ERC20.sol";

import {ERC721} from "openzeppelin/token/ERC721/ERC721.sol";
import {ERC721Enumerable} from "openzeppelin/token/ERC721/extensions/ERC721Enumerable.sol";

import {Ownable} from "openzeppelin/access/Ownable.sol";

import "forge-std/Test.sol";

contract EnumNft is ERC721Enumerable, Ownable {
    constructor(
        string memory name,
        string memory symbol
    ) ERC721(name, symbol) {}

    function mint(address to) external onlyOwner returns (uint256 tokenId) {
        uint256 totalSupply = totalSupply();
        tokenId = totalSupply + 1;
        _safeMint(to, tokenId);
    }
}

contract NftPool is ERC20, IERC721Receiver {
    mapping(address => uint256) public balances;

    // owner's address => nft id => bool
    mapping(address => mapping(uint256 => bool)) private lockedAsset;

    ERC721Enumerable public nft;

    constructor(
        string memory name,
        string memory symbol,
        address tokenAddress
    ) ERC20(name, symbol) {
        nft = ERC721Enumerable(tokenAddress);
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) external returns (bytes4) {
        // console.log('onERC721Received');
        return this.onERC721Received.selector;
    }

    function leave(uint256 id) external {
        require(lockedAsset[msg.sender][id], "Only owner can leave the pool");
        nft.safeTransferFrom(address(this), msg.sender, id);
        delete lockedAsset[msg.sender][id];
        balances[msg.sender] -= 1;
    }

    function enter(uint256 id) external {
        nft.safeTransferFrom(msg.sender, address(this), id);
        lockedAsset[msg.sender][id] = true;
        balances[msg.sender] += 1;
    }
}

contract Contest {
    EnumNft public nft;
    NftPool public nftPool;
    uint256 public tokenId;
    address public challenger;

    constructor() {
        nft = new EnumNft("Bee NFT", "BeeNFT");
        nftPool = new NftPool("Bee Pool", "BeePool", address(nft));
    }

    function init() public {
        tokenId = nft.mint(msg.sender);
    }

    function solve() public view returns (bool) {
        require(nftPool.balances(msg.sender) > 1000, "You should be rich");
        return true;
    }
}