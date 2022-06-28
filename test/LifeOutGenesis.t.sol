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

        mintCost = testLifeOutGenesis.MINT_COST();
        limitByAddress = testLifeOutGenesis.LIMIT_NFT_BY_ADDRES();
        NFTLifeOut = testLifeOutGenesis.AVAILABLE_SUPPLY();
    }

    function buyManyAcount() public {
        for(uint i = 0; i < 333; i++){
            address cuenta = cheats.addr(i+1);
            cheats.deal(cuenta, 2 ether);

            cheats.prank(cuenta);
            
            testLifeOutGenesis.mintLifeOutGenesis
            {value: mintCost * limitByAddress}(limitByAddress);
        }
    }
    function testBuyNft() public {       

        buyManyAcount();

        // for(uint i = 0; i < 333; i++){
        //     address cuenta = cheats.addr(i+1);
        //     cheats.deal(cuenta, 2 ether);

        //     cheats.prank(cuenta);
            
        //     testLifeOutGenesis.mintLifeOutGenesis
        //     {value: mintCost * limitByAddress}(limitByAddress);
        // }

        assertEq(NFTLifeOut, testLifeOutGenesis.tokenIdCounter() - 1);
        assertEq(mintCost * NFTLifeOut , address(testLifeOutGenesis).balance);
        
    }

}