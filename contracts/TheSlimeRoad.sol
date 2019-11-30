pragma solidity >=0.4.21 <0.6.0;

import "../node_modules/@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "../math/SafeMath.sol";
import "../utils/Address.sol";
import "../node_modules/@openzeppelin/contracts/introspection/ERC165.sol";

import "./Escargots.sol";  

contract TheSlimeRoad is ERC165, IERC721 {



  mapping(uint256 => uint256) escargotsToSell;

  struct Sale {
    uint256 tokenId;
    address payable seller;
    uint256 price;
  }

  Sale[] public salesId;

  function deposit(uint256 _tokenId, uint256 _price) public {
    require(ownerOf(_tokenId) == msg.sender);

    safeTransferFrom(msg.sender, address(this) , _tokenId);

    Sale memory s = Sale({
            tokenId: _tokenId,
            seller: msg.sender,
            price: _price
        });
    uint256 saleId = salesId.push(s) - 1;

    escargotsToSell[_tokenId] = saleId;
  }

  function cancelSale(uint256 _tokenId) public {
    require(salesId[escargotsToSell[_tokenId]].seller == msg.sender);

    delete salesId[escargotsToSell[_tokenId]];
    delete escargotsToSell[_tokenId];

    safeTransferFrom(address(this), msg.sender, _tokenId);
  }

  function buy(uint256 _saleId) public payable {
    Sale storage buy = salesId[_saleId ];
    require(msg.value >= buy.price );

    buy.seller.transfer(msg.value);


    approve(msg.sender , buy.tokenId );
    safeTransferFrom(address(this), msg.sender, buy.tokenId);

    
  }

}