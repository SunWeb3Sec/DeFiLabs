// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

interface AggregatorV3Interface {
  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int answer,
      uint startedAt,
      uint updatedAt,
      uint80 answeredInRound
    );
}

contract ContractTest is Test {

  AggregatorV3Interface chainlink = AggregatorV3Interface(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419);

  function setUp() public {
    vm.createSelectFork("mainnet", 15327706);
  }

  function testgetLatestPrice() public {

  (uint80 roundID,int price,uint startedAt,uint timeStamp,uint80 answeredInRound) = chainlink.latestRoundData();

  emit log_named_int("ETH/USD price:", price/1e8);
  }
}