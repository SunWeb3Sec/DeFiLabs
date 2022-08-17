// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "./interfaces/ICompound.sol";
import "./interfaces/IERC20.sol";
import "./interfaces/cheat.sol";

contract ContractTest is Test {

  CErc20 COMP = CErc20(0xc00e94Cb662C3520282E6f5717214004A7f26888);
  //CErc20 C_COMP = CErc20(0x70e36f6BF80a52b3B46b3aF8e106CC0ed743E8e4);
  Comptroller comptroller = Comptroller(0x3d9819210A31b4961b30EF54bE2aeD79B9c9Cd3B);
  Governance governance = Governance(0xc0Da02939E1441F497fd74F78cE7Decb17B66529); 

  address cToken = 0xccF4429DB6322D5C611ee964527D42E5d685DD6a; //c_wbtc

  CheatCodes cheats = CheatCodes(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

  function setUp() public {
    vm.createSelectFork("mainnet", 15357717);
    vm.prank(0xfbe18f066F9583dAc19C88444BC2005c99881E56);
    COMP.transfer(address(this),100000 * 1e18);

  }

  function testSubmitProposal() public {
    console.log("----Before testing check status----");
    emit log_named_decimal_uint("COMP balance:", COMP.balanceOf(address(this)),18);

    console.log("----Submit proposal----");
    COMP.delegate(address(this));

        address[] memory _target = new address[](1);
        uint[] memory _value = new uint[](1);
        string[] memory _signature = new string[](1);
        bytes[] memory _calldata = new bytes[](1);

        _target[0] = address(COMP);
        _value[0] = 0;
        _signature[0] = "transfer(address,uint256)";
        _calldata[0] = abi.encode(
            address(this), 200000 * 1e18
        );
        vm.roll(15357719);
         //console.log("getPriorVotes",COMP.getPriorVotes(address(this),15357718) );
       //  console.log("getCurrentVotes",COMP.getCurrentVotes(address(this)) );
   (uint proposalid) = governance.propose(_target, _value, _signature, _calldata, 'Add the FTS token as collateral.');
    console.log("Proposalid",proposalid );
  }

}