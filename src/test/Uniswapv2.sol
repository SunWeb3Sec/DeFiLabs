// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

import "forge-std/Test.sol";
import "./interfaces/IWETH9.sol";
import "./interfaces/IUniswap.sol";
import "./interfaces/IERC20.sol";

contract ContractTest is Test {
  IERC20 WBTC = IERC20(0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599);
  IERC20 DAI = IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);
  WETH9 WETH = WETH9(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
  IUniswapV2Router UNISWAP_V2_ROUTER = IUniswapV2Router(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

  function setUp() public {
    vm.createSelectFork("mainnet", 15327706); //fork mainnet at block 15012670
    vm.startPrank(0x218B95BE3ed99141b0144Dba6cE88807c4AD7C09);
    WBTC.transfer(address(this),100000000); // transfer 1 BTC to self-contract

  }
 
  function testUniswapv2_swap() public {

    console.log("----Swap 1 WBTC to DAI----");
    swap(address(WBTC),address(DAI),100000000,1,address(this));
    emit log_named_uint("DAI balance:", DAI.balanceOf(address(this))/1e18);
    emit log_named_uint("WBTC balance:", WBTC.balanceOf(address(this))/1e18);
  }
   function swap(
    address _tokenIn,
    address _tokenOut,
    uint _amountIn,
    uint _amountOutMin,
    address _to
  ) public {
    IERC20(_tokenIn).approve(address(UNISWAP_V2_ROUTER), _amountIn);

    address[] memory path;
    if (_tokenIn == address(WETH) || _tokenOut == address(WETH) ) {
      path = new address[](2);
      path[0] = _tokenIn;
      path[1] = _tokenOut;
    } else {
      path = new address[](3);
      path[0] = _tokenIn;
      path[1] = address(WETH) ;
      path[2] = _tokenOut;
    }

    IUniswapV2Router(UNISWAP_V2_ROUTER).swapExactTokensForTokens(
      _amountIn,
      _amountOutMin,
      path,
      _to,
      block.timestamp
    );
  }
}
