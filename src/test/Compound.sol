// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "./interfaces/ICompound.sol";
import "./interfaces/IERC20.sol";
import "./interfaces/cheat.sol";

contract ContractTest is Test {

  IERC20 WBTC = IERC20(0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599);
  CErc20 C_WBTC = CErc20(0xccF4429DB6322D5C611ee964527D42E5d685DD6a);
  IERC20 DAI = IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);
  CErc20 CDAI = CErc20(0x5d3a536E4D6DbD6114cc1Ead35777bAB948E3643);
  Comptroller comptroller = Comptroller(0x3d9819210A31b4961b30EF54bE2aeD79B9c9Cd3B);
  PriceFeed priceFeed = PriceFeed(0x922018674c12a7F0D394ebEEf9B58F186CdE13c1); //UniswapAnchoredView
  uint supplyRate;
  uint exchangeRate;
  uint estimateBalance;
  uint balanceOfUnderlying;
  uint borrowedBalance;
  uint price;
  uint rerror; 
  uint liquidity; 
  uint shortfall;
  uint colFactor;
  uint supplied;
  uint liqbalance;
  address cToken = 0xccF4429DB6322D5C611ee964527D42E5d685DD6a; //c_wbtc
  uint256 MAX_INT = 2**256 - 1;
  CheatCodes cheats = CheatCodes(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

  function setUp() public {
    vm.createSelectFork("mainnet", 12856077);
    vm.prank(0x0C4809bE72F9E117D75381438c5dAeC8AbE75BaD);
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
    emit log_named_uint("supplied:", balanceOfUnderlying);
  }

  function testliquidate() public {
    //getCollateralFactor

    console.log("----Test Supply: 1 BTC----");
    C_WBTC.mint(100000000); // supply 1 btc.
    emit log_named_decimal_uint("C_WBTC balance of borrower:", C_WBTC.balanceOf(address(this)),8);
    (, colFactor, ) = comptroller.markets(address(C_WBTC));
    emit log_named_decimal_uint("colFactor: %", colFactor,16);

    supplied = C_WBTC.balanceOfUnderlying(address(this));
    emit log_named_decimal_uint("supplied: ", supplied/100,6);

    price = priceFeed.getUnderlyingPrice(address(CDAI));
    emit log_named_decimal_uint("CDAI price: ", price,18);

    console.log("----Test Borrow----");
    address[] memory cTokens = new address[](1);
    cTokens[0] = address(cToken);
    uint[] memory errors = comptroller.enterMarkets(cTokens);
     (uint error, uint liquidity, uint shortfall) = comptroller.getAccountLiquidity(
      address(this)
    );

    emit log_named_decimal_uint("liquidity:", liquidity/10000,14);
    emit log_named_decimal_uint("shortfall:", shortfall/10000,14);

    // calculate max borrow
    price = priceFeed.getUnderlyingPrice(address(CDAI));
    emit log_named_decimal_uint("CDAI Price:", price,18);

    // liquidity - USD scaled up by 1e18
    // price - USD scaled up by 1e18
    // decimals - decimals of token to borrow
    uint maxBorrow = (liquidity * (10**18)) / price;
    emit log_named_decimal_uint("maxBorrow", maxBorrow,18);


    CDAI.borrow(20528281942644085640092);
    emit log_named_decimal_uint("Borrowed DAI:", DAI.balanceOf(address(this)),18);
    
    CDAI.borrowBalanceCurrent(address(this));
    borrowedBalance = CDAI.borrowBalanceCurrent(address(this));
    emit log_named_decimal_uint("borrowedBalance:", borrowedBalance,18);
    ( rerror,  liquidity,  shortfall) = comptroller.getAccountLiquidity(
      address(this)
    );
    emit log_named_decimal_uint("Borrowed, liquidity:", liquidity/10000,14);
    emit log_named_decimal_uint("Borrowed, shortfall:", shortfall/10000,14);


    vm.roll(12866077);
    console.log("----After some blocks---");
    liqbalance =DAI.balanceOf(0xcd6Eb888e76450eF584E8B51bB73c76ffBa21FF2);
    emit log_named_uint("Liquidator DAI balance:", liqbalance/10**18);

// cheats.mockCall(address(comptroller),abi.encodeWithSelector(Comptroller.getAccountLiquidity.selector),abi.encode(0,0,1000000000000000000));
    // problem here: how to manipulate price or borrow amount to make collateral to be liquidated?
    ( error,  liquidity, shortfall) = comptroller.getAccountLiquidity(
      address(this)
    );

    emit log_named_decimal_uint("Afterliquidity:", liquidity/10000,14);
    emit log_named_decimal_uint("Aftershortfall:", shortfall/10000,14);

    uint closeFactor = comptroller.closeFactorMantissa();
    emit log_named_uint("closeFactor:", closeFactor/10**16);
    uint repayAmount = (borrowedBalance * closeFactor)/10**18;
    emit log_named_uint("repayAmount:", repayAmount/10**18);


    (uint e, uint cTokenCollateralAmount) = comptroller
    .liquidateCalculateSeizeTokens(
      address(CDAI),
      address(C_WBTC),
      repayAmount
    );
    emit log_named_uint("amountToBeLiquidated:", cTokenCollateralAmount/10**6/100);
 
 

    console.log("----Test liquidation----");
   // repay(address(DAI),address(CDAI),MAX_INT);
    emit log_named_uint("Borrowed DAI:", DAI.balanceOf(address(this))/1e18);
    vm.startPrank(0xcd6Eb888e76450eF584E8B51bB73c76ffBa21FF2);
    DAI.approve(address(CDAI),repayAmount);

    //Liquidate here, the sender liquidates the borrowers collateral.
    //The collateral seized is transferred to the liquidator.
    CDAI.liquidateBorrow(address(this),repayAmount,address(C_WBTC));


    supplied = C_WBTC.balanceOfUnderlying(address(this));
    emit log_named_decimal_uint("supplied: ", supplied/100,6);
    
    borrowedBalance = CDAI.borrowBalanceCurrent(address(this));
    emit log_named_uint("borrowedBalance:", borrowedBalance/1e18);

    uint incentive = comptroller.liquidationIncentiveMantissa();
    emit log_named_decimal_uint("incentive:", incentive/100,16); //1.08%

    uint liquidated = C_WBTC.balanceOfUnderlying(address(0xcd6Eb888e76450eF584E8B51bB73c76ffBa21FF2));
    emit log_named_decimal_uint("liquidated: ", liquidated/10000,4); //0.3411

    emit log_named_decimal_uint("C_WBTC balance of liquidator:", C_WBTC.balanceOf(0xcd6Eb888e76450eF584E8B51bB73c76ffBa21FF2),8);
    
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
    price = priceFeed.getUnderlyingPrice(_cTokenToBorrow);

    // liquidity - USD scaled up by 1e18
    // price - USD scaled up by 1e18
    // decimals - decimals of token to borrow
    uint maxBorrow = (liquidity * (10**_decimals)) / price;
    emit log_named_uint("maxBorrow", maxBorrow);

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