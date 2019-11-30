pragma solidity >=0.4.21 <0.6.0;

import "../node_modules/@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "../math/SafeMath.sol";
import "../utils/Address.sol";
import "../node_modules/@openzeppelin/contracts/introspection/ERC165.sol";

import "./Escargots.sol";  

contract TheSlimeRoad is ERC165, IERC721 {

  //mapping from tokenId to SaleId
  mapping(uint256 => uint256) escargotsToSell;

  struct Sale {
    uint256 tokenId;
    address payable seller;
    uint256 price;
  }

  Sale[] public salesId;
  //deposit a token to be sold
  function deposit(uint256 _tokenId, uint256 _price) public {
    require(ownerOf(_tokenId) == msg.sender);// require that you own the token you want to sell

    safeTransferFrom(msg.sender, address(this) , _tokenId);// token owner must approve this contract first to be able to sell

    //create new sale
    Sale memory s = Sale({
            tokenId: _tokenId,
            seller: msg.sender,
            price: _price
        });
    uint256 saleId = salesId.push(s) - 1;

    escargotsToSell[_tokenId] = saleId;
  }

  //function to withdraw a token you don't want to sell anymore
  function cancelSale(uint256 _tokenId) public {
    require(salesId[escargotsToSell[_tokenId]].seller == msg.sender);// you can only pull tokens you own

    delete salesId[escargotsToSell[_tokenId]];
    delete escargotsToSell[_tokenId];

    safeTransferFrom(address(this), msg.sender, _tokenId);//give back the token to owner
  }

  function buy(uint256 _saleId) public payable {
    Sale storage buy = salesId[_saleId ];
    require(msg.value >= buy.price );//require you send enough money
    //to do : give back change if you send to much money

    buy.seller.transfer(msg.value);//transfer money to token owner


    approve(msg.sender , buy.tokenId );//this contract approves the token buyer
    safeTransferFrom(address(this), msg.sender, buy.tokenId);//the transfers the token to the buyer

    
  }

}