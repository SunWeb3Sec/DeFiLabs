// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "./interfaces/ICompound.sol.sol";
import "./interfaces/IERC20.sol";


contract ContractTest is Test {

  IERC20 WBTC = IERC20(0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599);
  CErc20 C_WBTC = CErc20(0xccF4429DB6322D5C611ee964527D42E5d685DD6a);
  uint supplyRate;
  uint exchangeRate;
  uint estimateBalance;
  uint balanceOfUnderlying;

  function setUp() public {
    vm.createSelectFork("mainnet", 15327706);
    vm.prank(0x218B95BE3ed99141b0144Dba6cE88807c4AD7C09);
    WBTC.transfer(address(this),100000000);
    WBTC.approve(address(C_WBTC), 100000000);
  }

  function testgetLatestPrice() public {
    console.log("----Before testing supply, all status:----");
    exchangeRate = C_WBTC.exchangeRateCurrent();
    emit log_named_uint("exchangeRate:", supplyRate);

    supplyRate = C_WBTC.supplyRatePerBlock();
    emit log_named_uint("supplyRate:", supplyRate);

    estimateBalance = estimateBalanceOfUnderlying();
    emit log_named_uint("estimateBalance:", estimateBalance);

    balanceOfUnderlying = C_WBTC.balanceOfUnderlying(address(this));
    emit log_named_uint("balanceOfUnderlying:", balanceOfUnderlying);

    C_WBTC.mint(100000000); // supply 1 btc.

    console.log("----After supplying, all status:----");
    emit log_named_uint("Supplied 1 btc to get C_WBTC:", C_WBTC.balanceOf(address(this)));

    exchangeRate = C_WBTC.exchangeRateCurrent();
    emit log_named_uint("exchangeRate:", supplyRate);

    supplyRate = C_WBTC.supplyRatePerBlock();
    emit log_named_uint("supplyRate:", supplyRate);

    estimateBalance = estimateBalanceOfUnderlying();
    emit log_named_uint("estimateBalance:", estimateBalance);

    balanceOfUnderlying = C_WBTC.balanceOfUnderlying(address(this));
    emit log_named_uint("balanceOfUnderlying:", balanceOfUnderlying);

    console.log("----Test supply interest ----");
    vm.roll(15337706);  // Get interest per block.
    exchangeRate = C_WBTC.exchangeRateCurrent();
    emit log_named_uint("exchangeRate:", supplyRate);
    balanceOfUnderlying = C_WBTC.balanceOfUnderlying(address(this));
    emit log_named_uint("balanceOfUnderlying:", balanceOfUnderlying);  


    console.log("----Test Redeem----");
    uint cTokenAmount = C_WBTC.balanceOf(address(this));
    C_WBTC.redeem(cTokenAmount);
    emit log_named_uint("Redeemed BTC:", WBTC.balanceOf(address(this)));
    balanceOfUnderlying = C_WBTC.balanceOfUnderlying(address(this));
    emit log_named_uint("balanceOfUnderlying:", balanceOfUnderlying);
  }



  function estimateBalanceOfUnderlying() public returns (uint) {
    uint cTokenBal = C_WBTC.balanceOf(address(this));
    uint exchangeRate = C_WBTC.exchangeRateCurrent();
    uint decimals = 8; // WBTC = 8 decimals
    uint cTokenDecimals = 8;

    return (cTokenBal * exchangeRate) / 10**(18 + decimals - cTokenDecimals);
  }

}