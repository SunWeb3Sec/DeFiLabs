// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "forge-std/Test.sol";
import "forge-std/console2.sol";
import "./interfaces/IWETH9.sol";
import "./interfaces/IRouter.sol";
import "./interfaces/IVault.sol";
import "./interfaces/IERC20.sol";

contract ContractTest is Test {
  
  IERC20 WBTC = IERC20(0x2f2a2543B76A4166549F7aaB2e75Bef0aefC5B0f);
  IERC20 USDC = IERC20(0xFF970A61A04b1cA14834A43f5dE4533eBDDB5CC8);
  WETH9 WETH = WETH9(0x82aF49447D8a07e3bd95BD0d56f35241523fBab1);
  IERC20 USDT = IERC20(0xFd086bC7CD5C481DCC9C85ebE478A1C0b69FCbb9);
  IERC20 DAI = IERC20(0xDA10009cBd5D07dd0CeCc66161FC93D7c9000da1);
  IRouter router = IRouter(0xaBBc5F99639c9B6bCb58544ddf04EFA6802F4064); 
  IVault vault = IVault(0x489ee077994B6658eAfA855C308275EAd8097C4A); 
  
  address constant reader = 0x22199a49A999c351eF7927602CFB187ec3cae489;    
  
  address[] path = [
    address(USDC),
    address(USDT)
  ];
  
  
  function setUp() public {
    vm.createSelectFork("arbitrum", 22552152); //fork arbitrum at block 22552152
	
	vm.label(address(WBTC), "WBTC");
    vm.label(address(USDT), "USDT");
	vm.label(address(DAI), "DAI");
    vm.label(address(WETH), "WETH");
    vm.label(address(router), "ROUTER");
	vm.label(address(vault), "VAULT");
	vm.label(address(reader), "READER");

	USDC.approve(address(router),1000000);		
	
    address here = address(this);
    vm.startPrank(0x1714400FF23dB4aF24F9fd64e7039e6597f18C2b);
    USDC.transfer(here, 1000000); // transfer 1M USDC to self-contract
    vm.stopPrank();
  
	}

  function testGmxSwap() public {

    console2.log("----Swap 1M USDC to USDT----");
    console2.log("USDT balance before swap:", USDT.balanceOf(address(this)));
    console2.log("USDC balance before swap:", USDC.balanceOf(address(this)));
    console2.log("----");
	router.swap(path,1000000,1,address(this));	
	console2.log("USDT balance after swap:", USDT.balanceOf(address(this)));
    console2.log("USDC balance after swap:", USDC.balanceOf(address(this)));
	console2.log("----");

   }  
 
 }
  
  

