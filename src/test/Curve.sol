// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "./interfaces/ICurveStableSwap.sol";
import "./interfaces/IERC20.sol";
import "./interfaces/IUSDT.sol";

//More tests https://github.com/curvefi/curve-contract/tree/master/tests

contract ContractTest is Test {

  IERC20 DAI = IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);
  IERC20 USDC = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
  USDT usdt = USDT(0xdAC17F958D2ee523a2206206994597C13D831ec7);
  StableSwap curve =StableSwap(0xbEbc44782C7dB0a1A60Cb6fe97d0b483032FF1C7);

  function setUp() public {
    vm.createSelectFork("mainnet", 15333641);
    vm.startPrank(0x72A53cDBBcc1b9efa39c834A540550e23463AAcB);
    USDC.transfer(address(this),1000000000);
    usdt.transfer(address(this),1000000000);
    vm.stopPrank();
    USDC.approve(address(curve),1000000000);
  }

  function testCurveSwap() public {
 

    console.log("----Test Swap: swap  USDT to DAI----");

    curve.exchange(1,0,100000000,1);
    emit log_named_uint("DAI:", DAI.balanceOf(address(this))/10e18);
    emit log_named_uint("USDT:", usdt.balanceOf(address(this))/10e6);
    emit log_named_uint("USDC:", USDC.balanceOf(address(this))/10e6);
  }



}