// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "hardhat/console.sol";

contract Marketplace is ReentrancyGuard {

    uint public immutable feePercent;
    address payable immutable feeAccount;
    uint public itemCount;

    constructor(uint _feePercent){
        feePercent = _feePercent;
        feeAccount = payable(msg.sender);
    }

    struct Item {
        uint itemId;
        IERC721 nft;
        uint tokenId;
        uint price;
        address payable seller;
        bool sold;
    }

    mapping(uint => Item) public items;


    function makeItem(IERC721 _nft, uint _tokenId, uint _price) external nonReentrant {

        require(_price > 0, "Price must be greater than 0");

        itemCount ++;

        _nft.transferFrom(msg.sender, address(this) , _tokenId);

        items[itemCount] = Item (
            itemCount,
            _nft,
            _tokenId,
            _price,
            payable(msg.sender),
            false
        );
    }

    function purchaseItem(uint _itemId) external payable nonReentrant {
        uint _totalPrice = getTotalPrice(_itemId);

        Item storage item = items[_itemId];

        require(_itemId > 0 && _itemId <= itemCount, "item doesn't exist");
        require(!item.sold, "item is already sold");
        require(msg.value >= _totalPrice, "not enough balance");

        item.seller.transfer(item.price);
        feeAccount.transfer(_totalPrice - item.price);

        item.sold = true;

        item.nft.transferFrom(address(this), msg.sender, item.tokenId);
    }
    
    function getTotalPrice(uint _itemId) view public returns(uint){
        return((items[_itemId].price * (100 + feePercent))/100);
    }

}