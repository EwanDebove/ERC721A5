pragma solidity >=0.4.21 <0.6.0;

//import "../node_modules/@openzeppelin/contracts/token/ERC721/IERC721.sol";
//import "../node_modules/@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
//import "../math/SafeMath.sol";
//import "../utils/Address.sol";
//import "../node_modules/@openzeppelin/contracts/introspection/ERC165.sol";

import "./Escargots.sol";  

contract TheSlimeRoad {

  address public escargotsAddress;

  function setEscargotsAddress(address _escargotsAddress) public {
   escargotsAddress  = _escargotsAddress;
  }

  Escargots escargotsInstance = Escargots(escargotsAddress);

  //mapping from tokenId to SaleId
  mapping(uint256 => uint256) escargotsToSell;

  struct Sale {
    uint256 tokenId;
    address payable seller;
    uint256 price;
    bool auction;
    uint256 bid;
    address bidder;
  }

  Sale[] public salesId;
  //deposit a token to be sold
  function deposit(uint256 _tokenId, uint256 _price, bool _auction) public {

    require(escargotsInstance.ownerOf(_tokenId) == msg.sender);// require that you own the token you want to sell

    escargotsInstance.safeTransferFrom(msg.sender, address(this) , _tokenId);// token owner must approve this contract first to be able to sell

    //create new sale
    Sale memory s = Sale({
            tokenId: _tokenId,
            seller: msg.sender,
            price: _price,
            auction: false,
            bid: 0,
            bidder: address(0)
        });

    if( _auction == true){
      s.auction = true;
      s.bid = _price;
      s.bidder = msg.sender;
    }

    uint256 saleId = salesId.push(s) - 1;

    escargotsToSell[_tokenId] = saleId;
  }

  //function to withdraw a token you don't want to sell anymore
  function cancelSale(uint256 _tokenId) public {
    require(salesId[escargotsToSell[_tokenId]].seller == msg.sender);// you can only pull tokens you own

    delete salesId[escargotsToSell[_tokenId]];
    delete escargotsToSell[_tokenId];

    escargotsInstance.approve(msg.sender , _tokenId );
    escargotsInstance.safeTransferFrom(address(this), msg.sender, _tokenId);//give back the token to owner
  }

  function buy(uint256 _saleId) public payable {
    Sale storage buy = salesId[_saleId ];
    require(msg.value >= buy.price );//require you send enough money

    buy.seller.transfer(buy.price);//transfer money to token owner
    msg.sender.transfer(msg.value - buy.price);//give back the change

    escargotsInstance.approve(msg.sender , buy.tokenId );//this contract approves the token buyer
    escargotsInstance.safeTransferFrom(address(this), msg.sender, buy.tokenId);//the transfers the token to the buyer

    delete escargotsToSell[buy.tokenId  ];
    Sale storage replacer = salesId[salesId.length - 1];
    salesId[_saleId] = replacer;
    salesId.length--;
  }

/*  function  putAuction(uint256  _tokenId, uint256 _price) public payable{
      
      deposit(_tokenId, _price);

      salesId[escargotsToSell[_tokenId]].auction  = true;
      salesId[escargotsToSell[_tokenId]].bid  = _price;
      salesId[escargotsToSell[_tokenId]].bidder  = salesId[escargotsToSell[_tokenId]].seller;

  }*/

  function bid(uint256  _saleId) public  payable{
      require(salesId[_saleId].auction == true);
      require(salesId[_saleId].bid < msg.value);

      salesId[_saleId].bidder.transfer(salesId[_saleId].bid);

      salesId[_saleId].bid = msg.value;
      salesId[_saleId].bidder = msg.sender;
  }

  function cashout(uint256  _saleId)public payable{
    require(salesId[_saleId].seller == msg.sender);
    require(salesId[_saleId].bidder > salesId[_saleId].price);
    msg.sender.transfer(salesId[_saleId].bid);
    escargotsInstance.approve(salesId[_saleId].bidder, salesId[_saleId].tokenId);
    escargotsInstance.safeTransferFrom(address(this), salesId[_saleId].bidder,salesId[_saleId].tokenId);

    delete escargotsToSell[salesId[_saleId].tokenId];
    Sale storage replacer = salesId[salesId.length - 1];
    salesId[_saleId] = replacer;
    salesId.length--;
  }

}