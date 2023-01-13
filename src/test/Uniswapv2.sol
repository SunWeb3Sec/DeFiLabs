// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

import "forge-std/Test.sol";
import "forge-std/console2.sol";
import "./interfaces/IWETH9.sol";
import "./interfaces/IUniswap.sol";
import "./interfaces/IERC20.sol";

contract ContractTest is Test {
  IERC20 WBTC = IERC20(0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599);
  IERC20 DAI = IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);
  WETH9 WETH = WETH9(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
  IUniswapV2Router UNISWAP_V2_ROUTER = IUniswapV2Router(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

  function setUp() public {
    vm.createSelectFork("mainnet", 15327706); //fork mainnet at block 15327706

    vm.label(address(WBTC), "WBTC");
    vm.label(address(DAI), "DAI");
    vm.label(address(WETH), "WETH");
    vm.label(address(UNISWAP_V2_ROUTER), "ROUTER");

    address here = address(this);
    vm.startPrank(0x218B95BE3ed99141b0144Dba6cE88807c4AD7C09);
    WBTC.transfer(here, 1*(10**WBTC.decimals())); // transfer 1 BTC to self-contract
    vm.stopPrank();
  }
 
  function testUniswapv2_swap() public {
    uint256 daiToDecimals = 10**DAI.decimals();
    uint256 wtbcToDecimals = 10**WBTC.decimals();

    console2.log("----Swap 1 WBTC to DAI----");
    console2.log("DAI balance before swap:", DAI.balanceOf(address(this))/daiToDecimals);
    console2.log("WBTC balance before swap:", WBTC.balanceOf(address(this))/wtbcToDecimals);
    console2.log("----");
    swap(address(WBTC),address(DAI),100000000,1,address(this));
    console2.log("DAI balance after swap:", DAI.balanceOf(address(this))/daiToDecimals);
    console2.log("WBTC balance after swap:", WBTC.balanceOf(address(this))/wtbcToDecimals);
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
