pragma solidity >=0.4.21 <0.6.0;

import "../node_modules/@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "../math/SafeMath.sol";
import "../utils/Address.sol";
import "../node_modules/@openzeppelin/contracts/introspection/ERC165.sol";

import "./Escargots.sol";  

contract Arena is ERC165, IERC721 {

  uint256[] fighters;

  function registerFighter(uint tokenId) public {
    require(ownerOf(tokenId) == msg.sender);

    transferFrom(msg.sender, address(this), tokenId);


  }

}