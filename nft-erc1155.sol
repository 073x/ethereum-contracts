/**
 *
 * 	Author: HK (0xThatGuy)
 *	Git: https://github.com/0xthatguy
 *	Desc: A ERC1155 based contract to mint multiple/bulk NFTs. 
 *
**/

pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.3/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.3/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.3/contracts/utils/Counters.sol";

contract ThatGuyNFT1155 is ERC1155Burnable, Ownable {
    event NFTBought(address _sourceAdr, address _destinationAdr, uint256 _price);
    event NFTBurned(uint256 _token, uint256 value);

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIDs;
    mapping (uint256 => address) public Creator;
    mapping (uint256 => uint256) public NFTPrice;
    mapping (uint256 => uint256) public NFTRoyalty;

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
    function mintBulkNFT(address recipient, uint256 amount, string memory tokenURI, uint256 royalty) external returns (uint256[] memory) {
        uint256[] memory amts = new uint256[](amount);
        uint256[] memory ids = new uint256[](amount);
        for(uint i=0;i<amount;i++){
            amts[i] = 1;
            _tokenIDs.increment();
            ids[i] = _tokenIDs.current();
            Creator[_tokenIDs.current()] = recipient; 
            NFTRoyalty[_tokenIDs.current()] = royalty;
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
    **/
    function listNFT(uint256 _tokenID, uint256 _price) external {
        require(balanceOf(msg.sender, _tokenID) > 0, "Authorization Error: NFT doesn't belong to the user.");
        require(_price > 0, 'Price must be greater than zero');
        NFTPrice[_tokenID] = _price;
    }



    /**
     *
     *      buyNFT: Sell NFT(s)
     *      @param sourceAdr: Seller/Owner address (key).
     *      @param destinationAdr: Buyer address (key).
     *      @param _tokenID: NFT ID (hash).
     *
     *      @eventEmitter NFTBought: To notify info regarding the transaction.
    **/
    function buyNFT(address sourceAdr, address destinationAdr, uint256 _tokenID) external payable {
        uint256 price = NFTPrice[_tokenID];
        address orgArtist = Creator[_tokenID];
        uint256 royalty = (price * NFTRoyalty[_tokenID]) / 1000;

        require(price > 0, 'The NFT is not listed or available for sale');
        require((msg.value) == price, "Error: The price doesn't match the value.");
        _safeTransferFrom(sourceAdr, destinationAdr, _tokenID, 1, "0x");

        if((sourceAdr != orgArtist) && (destinationAdr != orgArtist)){
            // send the ETH royalty to creater
            payable(orgArtist).transfer(royalty); 
            // send the ETH to the owner
            payable(fromaddr).transfer(price - royalty);
        } else {
            // send the ETH to the owner without royalty
            payable(sourceAdr).transfer(price);
        }

        emit NFTBought(sourceAdr, destinationAdr, price);
    }


    /**
     *
     *      burnNFT: Delete NFT(s)
     *      @param _tokenID: NFT ID (hash).
     *      @param value: 
     *
     *      @eventEmitter NFTBurned: To notify info regarding the NFT status.
    **/
    function burnNFT(uint256 _tokenId, uint256 value) external {
        require(balanceOf(msg.sender, _tokenID) > 0, "Authorization Error: NFT doesn't belong to the user.");
        delete NFTPrice[_tokenID];
        delete NFTRoyalty[_tokenID];
        delete Creator[_tokenID];

        _burn(msg.sender, _tokenID, value);

        emit NFTBurned(_tokenID, value);
    }

}