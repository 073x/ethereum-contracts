/**
 *
 *	Author: HK (0xThatGuy)
 *	Git: https://github.com/0xthatguy
 *	Desc: A ERC721 based contract to mint single NFTs. 
 *
**/


pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import 'https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol';


contract ThatGuyNFT721 is ERC721 {
    event NFTBought(address _sourceAdr, address _destinationAdr, uint256 _price);

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIDs;

    mapping (uint256 => uint256) public NFTPrice;
    mapping (uint256 => address) public Creator;

    constructor() public ERC721("ThatGuyNFT", "API") {}

    /**
     *
     *      mintNFT: Mint the NFT.
     *      @param recipient: Creator's address (key).
     *      @param tokenURI
     *
    **/
    function mintNFT(address recipient, string memory tokenURI)
        public
        returns (uint256)
    {
        _tokenIDs.increment();

        uint256 newItemId = _tokenIDs.current();
        _mint(recipient, newItemId);
        _setTokenURI(newItemId, tokenURI);

        return newItemId;
    }

    /**
     *
     *      setPrice: To declare the price of the NFT.
     *      @param _tokenID: NFT hash/ID.
     *      @param _price: Price of the NFT.
     *      @param  _tokenAddress: 
     *
    **/
    function setPrice(uint256 _tokenID, uint256 _price, address _tokenAddress) external {
        require(msg.sender == ownerOf(_tokenID), "Authorization Error: The NFT doesn't belong to the user.");
        NFTPrice[_tokenID] = _price;
        Creator[_tokenID] = _tokenAddress;
    }

    /**
     *
     *      listNFT: To list the NFT for sale (Avail the NFT for sale).
     *      @param _tokenID: NFT hash/ID.
     *      @param _price: Price of the NFT.
     *
    **/
    function listNFT(uint256 _tokenID, uint256 _price) external {
        require(msg.sender == ownerOf(_tokenID), "Authorization Error: The NFT doesn't belong to the user.");
        require(_price > 0, 'The price must be greater than zero');
        NFTPrice[_tokenID] = _price;
    }


    /**
     *
     *      unlistNFT: To unlist the NFT for sale (Unavail the NFT for sale).
     *      @param _tokenID: NFT hash/ID.
     *
    **/
    function unlistNFT(uint256 _tokenID) external {
        require(msg.sender == ownerOf(_tokenID), "Authorization Error: The NFT doesn't belong to the user.");
        NFTPrice[_tokenID] = 0;
    }


    /**
     *
     *      buyNFT: To initiate a NFT sale transaction.
     *      @param _tokenID: NFT hash/ID.
     *
    **/
    function buyNFT(uint256 _tokenID) external payable {
        uint256 price = NFTPrice[_tokenID];
        require(price > 0, 'The NFT is not listed for sale.');
        require(msg.value == price, "The price doesn't match the value");

        address source = ownerOf(_tokenID);
        address tokenAddress = Creator[_tokenID];

        if(address != address(0){
            IERC20 tokenContract = IERC20(tokenAddress);
            require(tokenContract.transferFrom(msg.sender, address(this), price),
                "buy: payment failed");
        } else {
            payable(source).transfer(msg.value);
        }
        _transfer(source, msg.sender, _tokenID);
        NFTPrice[_tokenID] = 0;
        

        emit NFTBought(source, msg.sender, msg.value);
    }
}
