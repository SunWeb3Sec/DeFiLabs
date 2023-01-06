// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

import "forge-std/Test.sol";
import "./interfaces/IWETH9.sol";
import "./interfaces/IUni_Pair_V2.sol";

contract ContractTest is Test {
  WETH9 weth = WETH9(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
  Uni_Pair_V2 UniswapV2Pair = Uni_Pair_V2(0xd3d2E2692501A5c9Ca623199D38826e513033a17);

  function setUp() public {
    vm.createSelectFork("mainnet", 15012670); //fork mainnet at block 15012670
  }

  function testUniswapv2_flashswap() public {
    weth.deposit{ value: 2 ether }();
    Uni_Pair_V2(UniswapV2Pair).swap(0, 100 * 1e18, address(this), "0x00");
  }

  function uniswapV2Call(
    address sender,
    uint256 amount0,
    uint256 amount1,
    bytes calldata data
  ) external {
    emit log_named_decimal_uint(
      "Before flashswap, WETH balance of user:",
      weth.balanceOf(address(this)),
      18
    );
    // 0.3% fees
    uint256 fee = ((amount1 * 3) / 997) + 1;
    uint256 amountToRepay = amount1 + fee;
    emit log_named_decimal_uint("Amount to repay:", amountToRepay,18);

    weth.transfer(address(UniswapV2Pair), amountToRepay);

    emit log_named_decimal_uint(
      "After flashswap, WETH balance of user:",
      weth.balanceOf(address(this)),
      18
    );
  }
  receive() external payable {}
}
