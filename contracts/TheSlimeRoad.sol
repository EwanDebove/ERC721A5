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
    address seller;
    uint256 price;
  }

  Sale[] public salesId;

  function deposit(uint256 _tokenId, uint256 _price) public {
    require(ownerOf(_tokenId) == msg.sender);

    transferFrom(msg.sender, address(this) , _tokenId);

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

    token.safeTransferFrom(address(this), msg.sender, _tokenId);
  }

  function buy(uint256 _saleId) public {
    
  }

}