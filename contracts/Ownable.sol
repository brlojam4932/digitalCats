// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract Ownable {

  address private _owner;

  modifier onlyOwner() {
    require(_owner == msg.sender);
    _;
  }


}