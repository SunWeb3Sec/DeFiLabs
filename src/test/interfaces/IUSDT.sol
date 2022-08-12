//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

interface USDT {
  function transfer(address to, uint256 value) external;

  function balanceOf(address account) external view returns (uint256);

  function approve(address spender, uint256 value) external;
}