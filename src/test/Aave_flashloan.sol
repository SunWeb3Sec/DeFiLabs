// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "forge-std/Test.sol";
import "./interfaces/IUSDT.sol";
import "./interfaces/ILendingPool.sol";
import "./interfaces/IERC20.sol";

contract ContractTest is Test {
  using SafeMath for uint;
  IERC20 WBTC = IERC20(0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599);
  USDT usdt = USDT(0xdAC17F958D2ee523a2206206994597C13D831ec7);

  ILendingPool aaveLendingPool =
    ILendingPool(0x7d2768dE32b0b80b7a3454c06BdAc94A69DDc7A9);

  address[] assets = [0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599];
  uint256[] amounts = [2700000000000];
  uint256[] modes = [0];

  event Log(string message, uint val);
  function setUp() public {
    vm.createSelectFork("mainnet", 15141656);
  }

  function testAave_flashloan() public {
    vm.prank(0x218B95BE3ed99141b0144Dba6cE88807c4AD7C09);
    WBTC.transfer(address(this),2430000000);
    emit log_named_uint(
      "Before flashloan, balance of WBTC:",
      WBTC.balanceOf(address(this))
    );
    aaveLendingPool.flashLoan(
      address(this),
      assets,
      amounts,
      modes,
      address(this),
      "0x",
      0
    );
    emit log_named_uint(
      "After flashloan repaid, balance of WBTC:",
       WBTC.balanceOf(address(this))
    );
  }

  function executeOperation(
    address[] memory assets,
    uint256[] memory amounts,
    uint256[] memory premiums,
    address initiator,
    bytes memory params
  ) public returns (bool) {
    assets;
    amounts;
    premiums;
    params;
    initiator;
    for (uint i = 0; i < assets.length; i++) {
        emit Log("borrowed", amounts[i]);
        emit Log("fee", premiums[i]);
        uint amountOwing = amounts[i].add(premiums[i]);
        WBTC.approve(address(aaveLendingPool), amountOwing);
    //If don't have insufficient balance, will trigger Reason: SafeERC20: low-level call failed.
    }
    return true;
  }

  receive() external payable {}
}