// SPDX-License-Identifier: AGPL-3.0-only

pragma solidity 0.8.4;

import {console} from "forge-std/console.sol";
import {stdStorage, StdStorage, Test} from "forge-std/Test.sol";
import "../src/LifeOutGenesis.sol";
import "forge-std/Test.sol";

interface CheatCodes {
    function addr(uint256) external returns (address);

    function deal(address who, uint256 newBalance) external;

    function prank(address) external;
}
contract LifeOut is Test {

    LifeOutGenesis public testLifeOutGenesis;

    CheatCodes cheats = CheatCodes(HEVM_ADDRESS);

    address public owner;
    address public addr1;
    address public addr2;

    uint256 public mintCost;
    uint256 public limitByAddress; 
    uint256 public NFTLifeOut; 


    function setUp() public {
        owner = address(this);        
        addr1 = cheats.addr(1);
        addr2 = cheats.addr(2);

        testLifeOutGenesis = new LifeOutGenesis();
        testLifeOutGenesis.setStartSale(true);

        mintCost = testLifeOutGenesis.mintCost();
        limitByAddress = testLifeOutGenesis.LIMIT_NFT_BY_ADDRES();
        NFTLifeOut = testLifeOutGenesis.AVAILABLE_SUPPLY();
    }
  

    function testNotChangeOwner() public {
        vm.expectRevert(bytes("Ownable: caller is not the owner"));
        cheats.prank(addr1);
        testLifeOutGenesis.transferOwnership(addr1);
    }

    function testChangeOwner() public {
        testLifeOutGenesis.transferOwnership(addr1);
        assertEq(testLifeOutGenesis.owner(), addr1);
    }

    function testSetNewMintCost() public {        
        testLifeOutGenesis.setMintCost(0.1 ether);
        assertEq(testLifeOutGenesis.mintCost(), 0.1 ether);
    }

    function testDoesNotChangeMintCost() public {
        vm.expectRevert(bytes("Ownable: caller is not the owner"));
        cheats.prank(addr1);
        testLifeOutGenesis.setMintCost(0.1 ether);
    }

    function testDoesNotSetStarSale() public {
        vm.expectRevert(bytes("Ownable: caller is not the owner"));
        cheats.prank(addr1);
        testLifeOutGenesis.setStartSale(true);
    }

    function testSetStartSale() public {
        testLifeOutGenesis.setStartSale(true);
        assertEq(testLifeOutGenesis.startSale(), true);
    }

    function testDoesNotSetBaseURI() public {
        vm.expectRevert(bytes("Ownable: caller is not the owner"));
        cheats.prank(addr1);
        testLifeOutGenesis.setBaseURI("new base URI");
    }

    function testSetBaseURI() public {
        testLifeOutGenesis.setBaseURI("new base URI");
        assertEq(testLifeOutGenesis.baseURI(), "new base URI");
    }

   
}