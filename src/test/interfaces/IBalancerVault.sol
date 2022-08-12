//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

interface IBalancerVault {
  function flashLoan(
    address recipient,
    address[] memory tokens,
    uint256[] memory amounts,
    bytes memory userData
  ) external;
}
