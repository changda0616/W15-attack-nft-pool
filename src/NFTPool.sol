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
        require(
            balanceOf(to) < 2,
            "Yon can only mint once"
        );
        uint256 totalSupply = totalSupply();
        tokenId = totalSupply + 1;
        _safeMint(to, tokenId);
    }
}

contract NftPool is ERC20, IERC721Receiver {
    mapping(address => uint256) public balances;

    // owner's address => nft id => bool
    mapping(address => mapping(uint256 => bool)) private enteredNFT;

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
        return this.onERC721Received.selector;
    }

    function enter(uint256 id) external {
        require(
            nft.ownerOf(id) == msg.sender,
            "Only owner can deposit their NFT"
        );
        require(!enteredNFT[msg.sender][id], "You can only enter once");
        nft.safeTransferFrom(msg.sender, address(this), id);
        enteredNFT[msg.sender][id] = true;
    }

    function leave(uint256 id) external {
        require(enteredNFT[msg.sender][id], "NFT should enter the pool.");
        require(nft.ownerOf(id) == address(this), "No NFT to be transfered");
        nft.safeTransferFrom(address(this), msg.sender, id);
        balances[msg.sender] += 1;
    }
}

contract Contest {
    EnumNft public nft;
    NftPool public nftPool;
    uint256 public tokenId;

    constructor() {
        nft = new EnumNft("Bee NFT", "BeeNFT");
        nftPool = new NftPool("Bee Pool", "BeePool", address(nft));
    }

    function init() public {
        require(!isContract(msg.sender), "Human only!!");
        tokenId = nft.mint(msg.sender);
    }

    function isContract(address account) public view returns (bool) {
        uint size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function solve() public view returns (bool) {
        require(nftPool.balances(msg.sender) > 100, "You should be rich");
        return true;
    }
}