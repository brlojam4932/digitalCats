// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
//import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./Ownable.sol";


  contract KittyContract is IERC721, IERC721Receiver, Ownable {

  //using SafeMath for uint256;  

  mapping(uint256 => address) public kittyIndexToOwner; // an interger or index to an address
  mapping(address => uint256) ownershipTokenCount; // an address to a number, a count
  mapping(address => uint256[]) ownerToCats; //an address to a number of cats in an array
  mapping(uint256 => address) kittyIndexToApproved; // point to another address to approve of transfer a tokens on the behalf of the owner

  //operator approval: first owner allows second owner to spend on his behalf

  // MY ADDR => OPPERATOR ADDR => TRUE/FALSE
  // _oppratorApprovals[myAddr][operatorAddr] = true/false
  mapping(address => mapping(address => bool)) private _operatorApprovals;
  // implement different functions to set approval, get approval and set approval for all and get approval for all
  // ex. 
  // _operatorApprovals[myAddr][bobsAddr] = true;
  // _operatorApprovals[myAddr][aliceAddr] = false;
  // _operatorApprovals[myAddr][joesAddr] = true;

  bytes4 internal constant MAGIC_ERC721_RECEIVED = (bytes4(keccak256("onERC721Received(address,address,uint256,bytes)")));

  // call onERC721Received in the _to contract
  bytes4 private constant _INTERFACE_ID_ERC721 = 0x80ac58cd;

  // bytes4(keccat256("supportInterface(bytes4)");

  bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

  event Birth(address owner, uint256 kittenId, uint256 mumId, uint256 dadId, uint256 genes);

  // if made 'public constant', getter functions would be created
  // automatically, thus there would be no need to create getter functions
  // it's optional

  uint256 public constant CERATION_LIMIT_GEN0 = 10; // max num of cats to be generated
  uint256 public gen0Counter;

  string private _name;
  string private _symbol;

  struct Kitty{
  uint64 birthTime;
  uint32 mumId;
  uint32 dadId;
  uint16 generation;
  uint256 genes;
}

Kitty[] kitties;

  constructor(string memory name_, string memory symbol_) {
    _name = name_;
    _symbol = symbol_;
    owner = msg.sender;
}

  function supportsInterface(bytes4 _interfaceId) external pure override returns (bool) {
    return ( _interfaceId == _INTERFACE_ID_ERC721 || _interfaceId == _INTERFACE_ID_ERC165);
  }
 
  function name() external view returns (string memory tokenName) { // tokenName exists only in memory, it can be something else
    return _name;
  }
  
  function symbol() external view returns (string memory tokenSymbol) {
    return _symbol;
  }

  // could be external but externals can only be called from outside not within this contract
  function totalSupply() public view returns (uint256 total) {
    return kitties.length;

  }

  function getAllCatsFor(address owner) public view returns (uint[] memory cats) {
    return  ownerToCats[owner];
  }


  function balanceOf(address owner) external view override returns (uint256 balance ) {
    return ownershipTokenCount[owner];
  }

  function ownerOf(uint256 tokenId) external view override returns (address owner) {
    address _owner = kittyIndexToOwner[tokenId];
    require(_owner != address(0), "ERC721: owner query for nonexistent token");

    return _owner;
  }

  
  function getKitty(uint256 tokenId) public view returns(uint256 birthTime, uint256 mumId, uint256 dadId, uint256 generation, uint256 genes) {
    Kitty storage returnKitty = kitties[tokenId]; // storage is a pointer, instead of using memory - - we do not make a local copy of it
    return (uint256(returnKitty.birthTime), uint256(returnKitty.mumId), uint256(returnKitty.dadId), uint256(returnKitty.generation), uint256(returnKitty.genes));
  }

   function getKittyFilip(uint256 _id) public view returns(
     uint256 birthTime, 
     uint256 mumId, 
     uint256 dadId, 
     uint256 generation, 
     uint256 genes) {

    Kitty storage kitty = kitties[_id];

    birthTime = uint256(kitty.birthTime);
    mumId = uint256(mumId);
    dadId = uint256(dadId);
    generation = uint256(kitty.generation);
    genes = kitty.genes;
  }


  function createKittyGen0(uint256 _genes) public onlyOwner returns(uint256){
    require(gen0Counter < CERATION_LIMIT_GEN0, "Gen 0 should be less than creation limit gen 0");

    gen0Counter++;

    // mum, dad and generation is 0
    // Gen0 have no owners; they are owned by the contract
   return  _createKitty(0,0,0, _genes, msg.sender); // msg.sender could also be -- address(this) - we are giving cats to owner

  }

  // create cats by generation and by breeding
  // retuns cat id
  function _createKitty(
    uint256 _mumId,
    uint256 _dadId,
    uint256 _generation, //1,2,3..etc
    uint256 _genes, // recipient
    address owner
  ) private returns(uint256) {
    Kitty memory newKitties = Kitty({ // create struct object
      genes: _genes,
      birthTime: uint64(block.timestamp),
      mumId: uint32(_mumId),
      dadId: uint32(_dadId),
      generation: uint16(_generation)
     });

     kitties.push(newKitties); // returns the size of array - 1 for the first cat

     uint256 newKittenId = kitties.length -1; // 0 -1

     emit Birth(owner, newKittenId, _mumId, _dadId, _genes);

     _transfer(address(0), owner, newKittenId); // birth of a cat from 0 (standard)

    return newKittenId; //returns 256 bit integer

  }

  function safeTransferFrom(address from, address to, uint256 tokenId) external override {
    _safeTransfer(from, to, tokenId, "" );
  }

  

  function transferFrom(address from, address to, uint256 tokenId) external override {
    require(_owns(from, tokenId), "Throws if `_from` is not the current owner.");
    require(to != address(0), "to cannot be the zero address" );
    require(tokenId < kitties.length, "not a valid NFT" );

    // spender is "from" OR spender is approved for tokenId OR spender is operator for "from".
    //require(msg.sender == from || _approvedFor(from, tokenId) || _setApprovalForAll(from, msg.sender));

    _transfer(from, to, tokenId);

}

function approve(address approved, uint256 tokenId) external override {
    address owner = kittyIndexToOwner[tokenId];
    require(msg.sender == address(0), "Throws error unless `msg.sender`" ); 
    require(approved != owner, "The zero address indicates there is no approved address." ); 
    require(_owns(msg.sender, tokenId), "msg.sender is owner of tokenId" );

    _toApprove(approved, tokenId);
    
    emit Approval(msg.sender, approved, tokenId);

  }

  function getApproved(uint256 tokenId) external view override returns (address) {
    require(tokenId < kitties.length);
    // 0,1,2,3,4
    // lenght = 5;

    return kittyIndexToApproved[tokenId];
  }

  function setApprovalForAll(address operator, bool _approved) external override {
    require(operator != msg.sender);
   
    _setApprovalForAll(operator, _approved);

    emit ApprovalForAll(msg.sender, operator, _approved);
  }

  function isApprovedForAll(address owner, address operator) external view override returns (bool) {
    // getter function
    // does this operator have approval from owner?
    return _operatorApprovals[owner][operator];
  }


  function _safeTransfer(address from, address to, uint256 tokenId, bytes calldata data) internal {
    _transfer(from, to, tokenId);
    require(_checkERC721Support(from, to, tokenId, data));
  }

  
  // must transfer from address 0
  function _transfer(address from,  address to, uint256 tokenId) internal {

    //ownershipTokenCount[to] = ownershipTokenCount[to].add(1);
    ownershipTokenCount[to] += 1;


    kittyIndexToOwner[tokenId] = to;

    // SEND tokenId # => an address to a number of cats in an array
    ownerToCats[to].push(tokenId);
    
    // decrease token count from person A to person B
    if (from != address(0)) {
      //ownershipTokenCount[from] = ownershipTokenCount[from].sub(1);
       ownershipTokenCount[from] -= 1;
        _removeTokenIdFromOwner(from, tokenId);
        delete kittyIndexToApproved[tokenId]; 
    }
      
  }

  function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external override {
    require(_owns(from, tokenId), "Throws if `_from` is not the current owner.");
    require(to != address(0), "to cannot be the zero address" );
    require(tokenId < kitties.length, "not a valid NFT" );

    // spender is "from" OR spender is approved for tokenId OR spender is operator for "from".
    require(msg.sender == from);
    require(_approvedFor(from, tokenId));
    //require(_setApprovalForAll(from, msg.sender));


    _safeTransfer(msg.sender, to, tokenId, data);

  }

  // available function to outside calls - it only sends from msg.sender to recipients
  function transfer(address to, uint256 tokenId) external {
    require(to != address(this), "to cannot be the contract address" );
    require(to != address(0),"to cannot be the zero address" );
    require(_owns(msg.sender, tokenId), "not the current NFT owner" );

    _transfer(msg.sender, to, tokenId);
    
    // might need to input _from instead of msg.sender to transfer from 0 address
    emit Transfer(msg.sender, to, tokenId);
  }

  function _removeTokenIdFromOwner(address owner, uint256 tokenId) internal {
    uint256 lastId = ownerToCats[owner][ownerToCats[owner].length -1];
    for (uint256 i = 0; i < ownerToCats[owner].length; i++) {
      if (ownerToCats[owner][i] == tokenId) {
          ownerToCats[owner][i] = lastId;
          ownerToCats[owner].pop();
      }

    }

  }

    
  function _owns(address _claimant, uint256 tokenId) internal view returns(bool) {
    return kittyIndexToOwner[tokenId] == _claimant;
  }


  function _setApprovalForAll(address operator, bool approved) internal {
    _operatorApprovals[msg.sender][operator] = approved;
  }

  function _toApprove(address approved, uint256 tokenId) internal {
    kittyIndexToApproved[tokenId] = approved;
  }

  // msg.sender and tokenId and check:
  // if kittyIndexToApproved for this _tokenId equals for this _claimant who claims they are approved
  // return true/false
  function _approvedFor(address _claimant, uint256 tokenId) internal view returns(bool) {
    return kittyIndexToApproved[tokenId] == _claimant;
  }

  // from addr => receiver addr
  function _checkERC721Support(address from, address to, uint256 tokenId, bytes calldata data) internal returns(bool) {
    if( !_isContract(to)) {
      //"not a valid contract"
      return true;
    } 

    bytes4 returnData = IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, data);
    return returnData == MAGIC_ERC721_RECEIVED;
    // call onERC721Received in the "to" contract
    // check return value
    // if there is an operator where "from", is not equal to msg.sender, then we use msg.sender

  }

  function _isContract(address to) internal view returns (bool) {
    uint32 size;
    assembly{
      size := extcodesize(to)
    }
    return size > 0;

  }

/*
  function _isApprovedOrOwner(address spender, address from, address to, uint256 tokenId) internal view {
    require(_owns(from, tokenId), "Throws if `_from` is not the current owner.");
    require(to != address(0), "to cannot be the zero address" );
    require(tokenId < kitties.length, "not a valid NFT" );

    // spender is "from" OR spender is approved for tokenId OR spender is operator for "from".
    require(spender == from || _approvedFor(from, tokenId) || _setApprovalForAll(from, msg.sender));
  }
  */

  


}