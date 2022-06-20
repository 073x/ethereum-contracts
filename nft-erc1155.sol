/*
	Author: HK (0xThatGuy)
	Git: https://github.com/0xthatguy
	Desc: A ERC1155 based contract to mint multiple NFTs. 
*/

pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.3/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.3/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.3/contracts/utils/Counters.sol";

contract ThatGuyNFT1155 is ERC1155Burnable, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIDs;
    mapping (uint256 => address) public originalArtist;
    mapping (uint256 => uint256) public NFTPrice;
    constructor() ERC1155("ThatGuyNFT") {}
    
    /**
    *
    *       mintBulkNFT: To mint bulk NFTs.
    *       @param recipient: Recipient/User Address (Key).
    *       @param amount: Price of NFT (*For each copy/NFT).
    *       @param tokenURI: 
    *
    *       @returns Array of processed Transaction IDs. 
    *
    */
    function mintBulkNFT(address recipient, uint256 amount, string memory tokenURI) external returns (uint256[] memory) {
        uint256[] memory amts = new uint256[](amount);
        uint256[] memory ids = new uint256[](amount);
        for(uint i=0;i<amount;i++){
            amts[i] = 1;
            _tokenIDs.increment();
            ids[i] = _tokenIDs.current();
            originalArtist[_tokenIDs.current()] = recipient; 
        }
        bytes memory extra = bytes(tokenURI);
        _mintBatch(recipient, ids, amts, extra);
        return ids;
    }

    /**
    *
    *       listNFT: To list user's NFTs (To avail NFT for sale).
    *       @param _tokenID: NFT ID/Hash.
    *       @param _price: Price of NFT.
    *
    */
    function listNFT(uint256 _tokenID, uint256 _price) external {
        require(balanceOf(msg.sender, _tokenID) > 0, "Authorization Error: NFT doesn't belong to the user.");
        require(_price > 0, 'Price must be greater than zero');
        NFTPrice[_tokenID] = _price;
    }
}