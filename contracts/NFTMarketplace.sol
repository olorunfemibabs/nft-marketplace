//SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

import "hardhat/console.sol";

contract NFTMarketplace is ERC721URIStorage {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIds;
    Counters.Counter private _itemsSold;
    
    address payable owner;

    struct MarketItem {
        uint256 tokenId;
        address payable seller;
        address payable owner;
        uint256 price;
        bool isSold; 
    }

    uint256 listingPrice = 0.0015 ether;

    mapping(uint256 => MarketItem) private idMarketItem;

    event idMarketItemCreated(
        uint256 indexed tokenId,
        address seller,
        address owner,
        uint256 price,
        bool isSold
    );

    constructor() ERC721("Asiwaju Nft", "ASJ") {
        owner = payable(msg.sender);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "only owner can");
        _;
    }

    function updateListingPrice(uint256 _listingPrice) 
        public 
        payable 
        onlyOwner 
        {
            listingPrice = _listingPrice;
        }


    function getListingPrice() public view returns(uint256) {
        return listingPrice;
    }

    //create a "create nft token function"

    function createToken(string memory tokenURI, uint256 price) 
        public 
        payable 
        returns(uint256) 
    {

        _tokenIds.increment();

        uint256 newTokenId = _tokenIds.current();

        _mint(msg.sender, newTokenId);
        _setTokenURI(newTokenId, tokenURI);

        createMarketItem(newTokenId, price);

        return newTokenId;
    } 

    //creating market items
    function createMarketItem(uint tokenId, uint price) private {
        require(price > 0, "Price must be above 1");
        require(msg.value == listingPrice, "Price must be equal to Listing Price");
        
         idMarketItem[tokenId] = MarketItem (
            tokenId,
            payable(msg.sender),
            payable(address(this)),
            price,
            false
         );

         _transfer(msg.sender, address(this), tokenId);

         emit idMarketItemCreated(
                tokenId, 
                msg.sender, 
                address(this), 
                price, 
                false 
            );


    }

    //creating function for resale token
    function reSellToken(uint256 tokenId, uint256 price) public payable {
        require(idMarketItem[tokenId].owner == msg.sender, "Only item owner can resell");
        require(msg.value == listingPrice, "Price must equal the listing price");

        idMarketItem[tokenId].isSold = false;
        idMarketItem[tokenId].price = price;
        idMarketItem[tokenId].seller = payable(msg.sender);
        idMarketItem[tokenId].owner = payable(address(this));

        _itemsSold.decrement();

        _transfer(msg.sender, address(this), tokenId);

        //creating function createmarketsale

    }

    

} 