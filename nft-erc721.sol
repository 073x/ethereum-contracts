/*
	Author: HK (0xThatGuy)
	Git: https://github.com/0xthatguy
	Desc: A ERC721 based contract to mint single NFTs. 
*/


pragma solidity ^0.7.3;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";


contract NFT is ERC721 {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIDs;

    constructor() public ERC721("NFT", "API") {}

    function mintNFT(address recipient, string memory tokenURI)
        public
        returns (uint256)
    {
        _tokenIds.increment();

        uint256 newItemId = _tokenIds.current();
        _mint(recipient, newItemId);
        _setTokenURI(newItemId, tokenURI);

        return newItemId;
    }
}
