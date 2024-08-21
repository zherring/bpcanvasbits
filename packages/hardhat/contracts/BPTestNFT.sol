// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract BPTestNFT is ERC1155, Ownable {
    uint256 public nextTokenId;

    constructor() ERC1155("https://api.example.com/metadata/{id}.json") {}

    function mint(address to, uint256 amount) external {
        _mint(to, nextTokenId, amount, "");
        nextTokenId++;
    }
}