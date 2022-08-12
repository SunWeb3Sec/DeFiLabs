// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.10;

import "forge-std/Test.sol";
import "./interfaces/IPancakePair.sol";
import "./interfaces/IWBNB.sol";
import "./interfaces/IERC20.sol";

contract Exploit is Test {
  IPancakePair wbnbBusdPair =  IPancakePair(0xaCAac9311b0096E04Dfe96b6D87dec867d3883Dc);
  WBNB wbnb = WBNB(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
  IERC20 busd = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);

  function setUp() public {
    vm.createSelectFork("bsc", 18671800);
  }

  function testBiswap_flashloan() public {
    (uint112 _reserve0, uint112 _reserve1, ) = wbnbBusdPair.getReserves();
    wbnbBusdPair.swap(
      _reserve0 - 1,
      _reserve1 - 1,
      address(this),
      new bytes(1)
    );
  }

  function BiswapCall(
    address sender,
    uint256 amount0,
    uint256 amount1,
    bytes calldata data
  ) public {
    emit log_named_uint(
      "After flashswap, WBNB balance of user:",
      wbnb.balanceOf(address(this)) / 1e18
    );
    emit log_named_uint(
      "After flashswap, BUSD balance of user:",
      busd.balanceOf(address(this)) / 1e18
    );
    wbnb.transfer(address(wbnbBusdPair), wbnb.balanceOf(address(this)));
    busd.transfer(address(wbnbBusdPair), busd.balanceOf(address(this)));
    //No enough balance, of course failed
  }

  receive() external payable {}
}
