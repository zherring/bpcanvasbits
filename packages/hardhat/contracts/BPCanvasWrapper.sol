// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract BPCanvasWrapper is ERC20, Ownable, IERC1155Receiver, ERC165 {
    IERC1155 public nftContract;

    // Mapping to track available token IDs and their quantities
    uint256[] public tokenIds;

    // Counter to track the total number of deposited NFTs
    uint256 public totalDepositedNFTs;

    constructor(address _nftContract) ERC20("BasePaint Canvas Wrapper", "PXLS") {
        nftContract = IERC1155(_nftContract);
    }

    function depositNFT(uint256 tokenId, uint256 amount) external {
        // Calculate the dynamic exchange rate based on the number of tokens held by the contract
        uint256 exchangeRate = getDynamicExchangeRate(tokenId);

        // Transfer the NFT from the sender to the contract
        nftContract.safeTransferFrom(msg.sender, address(this), tokenId, amount, "");

        // Update available tokens and total deposited NFTs
        if (availableTokens[tokenId] == 0) {
            tokenIds.push(tokenId);
        }
        availableTokens[tokenId] += amount;
        totalDepositedNFTs += amount;

        // Mint ERC20 tokens based on the dynamic exchange rate
        _mint(msg.sender, exchangeRate * amount);
    }

    function withdrawRandomNFT() external {
        // Calculate the average value of all NFTs in the pool
        uint256 averageValue = getAverageValue();

        // Check if the msg.sender has enough ERC20 tokens
        require(balanceOf(msg.sender) >= averageValue, "Insufficient balance");

        // Burn the average value of ERC20 tokens from msg.sender
        _burn(msg.sender, averageValue);

        // Get a random token ID
        uint256 tokenId = getRandomTokenId();

        // Transfer the NFT from the contract to msg.sender
        nftContract.safeTransferFrom(address(this), msg.sender, tokenId, 1, "");

        // Update available tokens and total deposited NFTs
        availableTokens[tokenId] -= 1;
        totalDepositedNFTs -= 1;
        if (availableTokens[tokenId] == 0) {
            removeTokenId(tokenId);
        }
    }

    function getDynamicExchangeRate(uint256 tokenId) public view returns (uint256) {
        // Get the number of tokens of the specified tokenId held by the contract
        uint256 balance = nftContract.balanceOf(address(this), tokenId);

        // Calculate the exchange rate based on the balance
        uint256 exchangeRate = 1000 / (balance + 1);

        return exchangeRate;
    }

    function getAverageValue() public view returns (uint256) {
        require(totalDepositedNFTs > 0, "No tokens available");

        // Calculate the average value by dividing the total ERC20 supply by the total number of deposited NFTs
        return totalSupply() / totalDepositedNFTs;
    }

    function getRandomTokenId() internal view returns (uint256) {
        require(tokenIds.length > 0, "No tokens available");

        // Generate a random index
        uint256 randomIndex = uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty))) % tokenIds.length;
        return tokenIds[randomIndex];
    }

    function removeTokenId(uint256 tokenId) internal {
        for (uint256 i = 0; i < tokenIds.length; i++) {
            if (tokenIds[i] == tokenId) {
                tokenIds[i] = tokenIds[tokenIds.length - 1];
                tokenIds.pop();
                break;
            }
        }
    }

    // Implementing IERC1155Receiver interface
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external override returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external override returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(IERC1155Receiver).interfaceId || super.supportsInterface(interfaceId);
    }
}