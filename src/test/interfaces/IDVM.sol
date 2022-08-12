//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

interface DVM {
  function flashLoan(
    uint256 baseAmount,
    uint256 quoteAmount,
    address assetTo,
    bytes calldata data
  ) external;

  function init(
    address maintainer,
    address baseTokenAddress,
    address quoteTokenAddress,
    uint256 lpFeeRate,
    address mtFeeRateModel,
    uint256 i,
    uint256 k,
    bool isOpenTWAP
  ) external;
}