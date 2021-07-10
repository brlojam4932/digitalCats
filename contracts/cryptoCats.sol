// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract myCryptoCats is ERC721, Ownable {

  constructor () ERC721( "myCryptoCats", "MCCT" ) {
  }

  bytes4 internal constant MAGIC_ERC721_RECEIVED = (bytes4(keccak256("onERC721Received(address,address,uint256,bytes)")));

   // call onERC721Received in the _to contract
  bytes4 private constant _INTERFACE_ID_ERC721 = 0x80ac58cd;

  // bytes4(keccat256("supportInterface(bytes4)");
  bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

  event Birth(address owner, uint256 kittenId, uint256 mumId, uint256 dadId, uint256 genes);

  uint256 public constant CERATION_LIMIT_GEN0 = 10; // max num of cats to be generated

  uint256 public gen0Counter;

  //an address to a number of cats in an array
  mapping(address => uint256[]) ownerToCats;

  struct Kitty{
  uint64 birthTime;
  uint32 mumId;
  uint32 dadId;
  uint16 generation;
  uint256 genes;
}

Kitty[] kitties;

  function totalSupply() public view returns (uint256 total) {
    return kitties.length;
  }

  function getAllCatsFor(address owner) public view returns (uint[] memory cats) {
    return  ownerToCats[owner];
  }

  function getKitty(uint256 tokenId) public view returns (uint256 birthTime, uint256 mumId, uint256 dadId, uint256 generation, uint256 genes ) {
    Kitty storage returnKitty = kitties[tokenId];
    return (uint256(returnKitty.birthTime), uint256(returnKitty.mumId), uint256(returnKitty.dadId), uint256(returnKitty.generation), uint256(returnKitty.genes) );
  }

  function getKittyFilip(uint256 _id) public view returns (
    uint256 birthTime,
    uint256 mumId,
    uint256 dadId,
    uint256 generation,
    uint256 genes 
    ) {

    Kitty storage kitty = kitties[_id];

    birthTime = uint256(kitty.birthTime);
    mumId = uint256(kitty.mumId);
    dadId = uint256(kitty.dadId);
    generation = uint256(kitty.generation);
    genes = uint256(kitty.genes);
    }

    function createKittyGen0(uint256 _genes) public onlyOwner returns(uint256) { // needs onlyOwner
      require(gen0Counter <= CERATION_LIMIT_GEN0, "Gen 0 should be less than creation limit gen 0" );

      gen0Counter++;

      // mum, dad and generation is 0
    // Gen0 have no owners; they are owned by the contract
    return _createKitty(0,0,0, _genes, msg.sender); // msg.sender could also be -- address(this) - we are giving cats to owner
    }

  // create cats by generation and by breeding
  // returns cat id
  function _createKitty(
    uint256 _mumId,
    uint256 _dadId,
    uint256 _generation, //1,2,3..etc
    uint256 _genes, // recipient
    address owner
  ) private returns(uint256) {
    Kitty memory newKitties = Kitty({
      genes: _genes,
      birthTime: uint64(block.timestamp),
      mumId: uint32(_mumId),
      dadId: uint32(_dadId),
      generation: uint16(_generation)
    });

    kitties.push(newKitties); // returns the size of array - 1 for the first cat

    uint256 newKittenId = kitties.length -1; // 0-1

    emit Birth(owner, newKittenId, _mumId, _dadId, _genes); // birth of a cat from 0 (standard)

    _transfer(address(0), owner, newKittenId);

    return newKittenId; //returns 256 bit integer

  }
  

}