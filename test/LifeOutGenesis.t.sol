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

    function setUp() public {
        owner = address(this);        
        addr1 = cheats.addr(1);
        addr2 = cheats.addr(2);

        testLifeOutGenesis = new LifeOutGenesis();
        testLifeOutGenesis.setStartSale(true);
    }

    function testBuyNft() public {

        uint256 mintCost = testLifeOutGenesis.MINT_COST();
        uint256 limitByAddress = testLifeOutGenesis.LIMIT_NFT_BY_ADDRES();

        for(uint i = 1; i < 334; i++){
            address cuenta = cheats.addr(i);
            cheats.deal(cuenta, 2 ether);

            cheats.prank(cuenta);
            
            testLifeOutGenesis.mintLifeOutGenesis
            {value: mintCost * limitByAddress}(limitByAddress);
        }
        console.log(testLifeOutGenesis.tokenIdCounter());
        console.log(address(testLifeOutGenesis).balance);
    }

}