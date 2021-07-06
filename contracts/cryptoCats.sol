// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./IERC721.sol";
import "./IERC721Receiver.sol";
import "./extensions/IERC721Metadata.sol";
import "../../utils/Address.sol";
import "../../utils/Context.sol";
import "../../utils/Strings.sol";
import "../../utils/introspection/ERC165.sol";

contract KittyContract is Context, ERC165, IERC721, IERC721Metadata {
    using Address for address;
    using Strings for uint256;

  mapping(uint256 => address) public kittyIndexToOwner;
  // an interger or index to an address
  mapping(address => uint256) ownershipTokenCount; // an address to a number, a count
  mapping(address => uint256[]) ownerToCats; //an address to a number of cats in an array
  mapping(uint256 => address) kittyIndexToApproved; // point to another address to approve of transfer a tokens on the behalf of the owner

  //operator approval: first owner allows second owner to spend on his behalf

  // MY ADDR => OPPERATOR ADDR => TRUE/FALSE
  // _oppratorApprovals[myAddr][operatorAddr] = true/false

  mapping (address => mapping(address => bool) ) private _operatorApprovals;

  // implement different functions to set approval, get approval and set approval for all and get approval for all
  // ex. 
  // _operatorApprovals[myAddr][bobsAddr] = true;
  // _operatorApprovals[myAddr][aliceAddr] = false;
  // _operatorApprovals[myAddr][joesAddr] = true;

uint256 public constant CERATION_LIMIT_GEN0 = 10; // max num of cats to be generated
uint256 public gen0Counter;

string public CryptoCatsToken;
string public CRTT;

struct Kitty{
  uint64 birthTime;
  uint32 mumId;
  uint32 dadId;
  uint16 generation;
  uint256 genes;
}

Kitty[] kitties;

 // Token name
    string private _name;

    // Token symbol
    string private _symbol;






}