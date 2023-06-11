// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import "forge-std/Test.sol";


interface IERC20 {
  event Approval(address indexed owner, address indexed spender, uint256 value);
  event Transfer(address indexed from, address indexed to, uint256 value);

  function name() external view returns (string memory);

  function symbol() external view returns (string memory);

  function decimals() external view returns (uint8);

  function totalSupply() external view returns (uint256);

  function balanceOf(address owner) external view returns (uint256);

  function allowance(address owner, address spender)
  external
  view
  returns (uint256);

  function approve(address spender, uint256 value) external returns (bool);

  function transfer(address to, uint256 value) external returns (bool);

  function transferFrom(
    address from,
    address to,
    uint256 value
  ) external returns (bool);
  function withdraw(uint256 wad) external;
  function deposit(uint256 wad) external returns (bool);
  function owner() external view virtual returns (address);
}

interface IDPPOracle {
    function flashLoan(
        uint256 baseAmount,
        uint256 quoteAmount,
        address _assetTo,
        bytes calldata data
    ) external;
}

interface CheatCodes {
  // Creates _and_ also selects a new fork with the given endpoint and block and returns the identifier of the fork
  function createSelectFork(string calldata,uint256) external returns(uint256);
  // Creates _and_ also selects a new fork with the given endpoint and the latest block and returns the identifier of the fork
  function createSelectFork(string calldata) external returns(uint256);
  // Takes a fork identifier created by `createFork` and sets the corresponding forked state as active.

}


contract ContractTest is Test {
    IDPPOracle DPPOracle =
        IDPPOracle(0xFeAFe253802b77456B4627F8c2306a9CeBb5d681);

    IERC20 BUSD = IERC20(0x55d398326f99059fF775485246999027B3197955);

    CheatCodes cheats = CheatCodes(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    function setUp() public {
        cheats.createSelectFork("bsc", 29010220);
    }

    function testExploit() public {
        
        emit log_named_decimal_uint(
            "BUSD balance before flashloan",
            BUSD.balanceOf(address(this)),
            BUSD.decimals()
        );

        DPPOracle.flashLoan(0, 30_000 * 1e18, address(this), new bytes(1));

    }

    function DPPFlashLoanCall(
        address sender,
        uint256 baseAmount,
        uint256 quoteAmount,
        bytes calldata data
    ) external {
        emit log_named_decimal_uint(
            "BUSD balance after flashloan",
            BUSD.balanceOf(address(this)),
            BUSD.decimals()
        );
        BUSD.transfer(address(DPPOracle), 30_000 * 1e18);
    }
}
