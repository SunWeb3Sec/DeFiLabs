// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

interface WBNB {
  function deposit() external payable;

  function withdraw(uint256 wad) external;

  function balanceOf(address account) external view returns (uint256);

  function transfer(address recipient, uint256 amount) external returns (bool);
}
