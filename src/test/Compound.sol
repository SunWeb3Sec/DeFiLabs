// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "./interfaces/ICompound.sol";
import "./interfaces/IERC20.sol";


contract ContractTest is Test {

  IERC20 WBTC = IERC20(0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599);
  CErc20 C_WBTC = CErc20(0xccF4429DB6322D5C611ee964527D42E5d685DD6a);
  IERC20 DAI = IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);
  CErc20 CDAI = CErc20(0x5d3a536E4D6DbD6114cc1Ead35777bAB948E3643);
  Comptroller comptroller = Comptroller(0x3d9819210A31b4961b30EF54bE2aeD79B9c9Cd3B);
  PriceFeed priceFeed = PriceFeed(0x922018674c12a7F0D394ebEEf9B58F186CdE13c1);
  uint supplyRate;
  uint exchangeRate;
  uint estimateBalance;
  uint balanceOfUnderlying;
  uint borrowedBalance;
  address cToken = 0xccF4429DB6322D5C611ee964527D42E5d685DD6a; //c_wbtc
  uint256 MAX_INT = 2**256 - 1;

  function setUp() public {
    vm.createSelectFork("mainnet", 15327706);
    vm.prank(0x218B95BE3ed99141b0144Dba6cE88807c4AD7C09);
    WBTC.transfer(address(this),100000000);
    WBTC.approve(address(C_WBTC), 100000000);
  }

  function testSupplyRedeem() public {
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

  function testBorrow() public {
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

    console.log("----Test Borrow----");

    borrow(address(CDAI),18);
    CDAI.borrowBalanceCurrent(address(this));
    borrowedBalance = CDAI.borrowBalanceCurrent(address(this));
    emit log_named_uint("borrowedBalance:", borrowedBalance/1e18);

    emit log_named_uint("Borrowed DAI:", DAI.balanceOf(address(this))/1e18);

    comptroller.getAccountLiquidity(address(this));

    console.log("----Test Repay----");
    repay(address(DAI),address(CDAI),MAX_INT);
    emit log_named_uint("Borrowed DAI:", DAI.balanceOf(address(this)));


    console.log("----Test Redeem----");
    uint cTokenAmount = C_WBTC.balanceOf(address(this));
    C_WBTC.redeem(cTokenAmount);
    emit log_named_uint("Redeemed BTC:", WBTC.balanceOf(address(this))); //0.99999999 btc
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

    // enter market and borrow
  function borrow(address _cTokenToBorrow, uint _decimals) public {
    // enter market
    // enter the supply market so you can borrow another type of asset
    address[] memory cTokens = new address[](1);
    cTokens[0] = address(cToken);
    uint[] memory errors = comptroller.enterMarkets(cTokens);
    require(errors[0] == 0, "Comptroller.enterMarkets failed.");

    // check liquidity
    (uint error, uint liquidity, uint shortfall) = comptroller.getAccountLiquidity(
      address(this)
    );
    require(error == 0, "error");
    require(shortfall == 0, "shortfall > 0");
    require(liquidity > 0, "liquidity = 0");

    // calculate max borrow
    uint price = priceFeed.getUnderlyingPrice(_cTokenToBorrow);

    // liquidity - USD scaled up by 1e18
    // price - USD scaled up by 1e18
    // decimals - decimals of token to borrow
    uint maxBorrow = (liquidity * (10**_decimals)) / price;
    require(maxBorrow > 0, "max borrow = 0");

    // borrow 50% of max borrow
    uint amount = (maxBorrow * 50) / 100;
   // emit log_named_uint("amount:", amount);   
    //CErc20(_cTokenToBorrow).borrow(amount) ;
    require(CErc20(_cTokenToBorrow).borrow(amount) == 0, "borrow failed");
  }

  function repay(
    address _tokenBorrowed,
    address _cTokenBorrowed,
    uint _amount
  ) public {
    IERC20(_tokenBorrowed).approve(_cTokenBorrowed, _amount);
    // _amount = 2 ** 256 - 1 means repay all
    require(CErc20(_cTokenBorrowed).repayBorrow(_amount) == 0, "repay failed");
  }
}