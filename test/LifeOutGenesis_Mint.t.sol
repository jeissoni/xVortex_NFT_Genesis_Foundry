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

    function expectRevert() external;

    function expectRevert(bytes4 msg) external;

    function expectRevert(bytes calldata msg) external;
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

    event Received(address sender, uint256 value);

    function buyManyAcount(uint256 numberAddress, uint256 numberNft) public {
        for(uint i = 0; i < numberAddress; i++){
            address cuenta = cheats.addr(i+1);
            cheats.deal(cuenta, 2 ether);

            cheats.prank(cuenta);
            
            testLifeOutGenesis.mintLifeOutGenesis
            {value: mintCost * numberNft}(numberNft);
        }
    }

    function setUp() public {
        owner = address(this);        
        addr1 = cheats.addr(1);
        addr2 = cheats.addr(2);

        testLifeOutGenesis = new LifeOutGenesis();


        mintCost = testLifeOutGenesis.mintCost();
        limitByAddress = testLifeOutGenesis.LIMIT_NFT_BY_ADDRES();
        NFTLifeOut = testLifeOutGenesis.AVAILABLE_SUPPLY();
    }

    function testBuyNft() public {       
        testLifeOutGenesis.setStartSale(true);
        buyManyAcount(333, limitByAddress);       
        assertEq(NFTLifeOut, testLifeOutGenesis.tokenIdCounter() - 1);
        assertEq(mintCost * NFTLifeOut , address(testLifeOutGenesis).balance);        
    }

    function testPrenventWithdrawFounds() public {
        testLifeOutGenesis.setStartSale(true);
        buyManyAcount(333, limitByAddress);        
        vm.expectRevert(bytes("Ownable: caller is not the owner"));
        cheats.prank(addr1);
        testLifeOutGenesis.withdrawProceeds();
    }

    function testWithdrawFoundsOnlyOwner() public {
        testLifeOutGenesis.setStartSale(true);
        buyManyAcount(333, limitByAddress);  
        uint256 balanceBefore = address(owner).balance;
        cheats.prank(owner);
        testLifeOutGenesis.withdrawProceeds();
        assertEq(address(testLifeOutGenesis).balance, 0);
        assertEq(address(owner).balance, balanceBefore + (mintCost * NFTLifeOut));
    }

    function testDoesNotMint_StartSaleNoOpen() public {
        
        cheats.deal(addr1, 2 ether);        
        
        cheats.expectRevert(
            abi.encodeWithSelector(
                LifeOutGenesis.SaleNotStarted.selector, addr1)
        );

        cheats.prank(addr1);
        testLifeOutGenesis.mintLifeOutGenesis(1);
    }

    function testDoesNotMint_IncorrectPayment() public {
        testLifeOutGenesis.setStartSale(true);
        cheats.deal(addr1, 2 ether);        
        cheats.expectRevert(
            abi.encodeWithSelector(
                LifeOutGenesis.IncorrectPayment.selector, addr1, 0)
        );

        cheats.prank(addr1);
        testLifeOutGenesis.mintLifeOutGenesis(1);
    }

    function testDoesNotMint_NftLimitPerDirection() public {
        
        testLifeOutGenesis.setStartSale(true);
        cheats.deal(addr1, 2 ether);        

        for(uint i = 0; i < limitByAddress - 1 ; i++){
            cheats.prank(addr1);            

            testLifeOutGenesis.mintLifeOutGenesis{value: mintCost}(1);
        }

        cheats.expectRevert(
            abi.encodeWithSelector(
                LifeOutGenesis.NftLimitPerDirection.selector, addr1, 2)
        );
        cheats.prank(addr1);       
        testLifeOutGenesis.mintLifeOutGenesis{value: mintCost * 2}(2);

    }

    function testDoesNotMint_NftSoldOut() public {
        address addr_1 = cheats.addr(333);
        address addr_2 = cheats.addr(334);
        cheats.deal(addr_1, 2 ether);
        cheats.deal(addr_2, 2 ether);        
        

        testLifeOutGenesis.setStartSale(true);
        buyManyAcount(332, limitByAddress);  

        cheats.prank(addr_1);    
        testLifeOutGenesis.mintLifeOutGenesis{value: mintCost * 2}(2);

        cheats.expectRevert(
            abi.encodeWithSelector(
                LifeOutGenesis.NftSoldOut.selector, addr_2)
        );
        cheats.prank(addr_2);       
        testLifeOutGenesis.mintLifeOutGenesis{value: mintCost * 3}(3);

        cheats.prank(addr_2);  
        testLifeOutGenesis.mintLifeOutGenesis{value: mintCost * 1}(1);
    }

    function testNotIncrement() public{
        testLifeOutGenesis.tokenIdCounter.increment();
    }
    receive() external payable {
        emit Received(msg.sender, msg.value);
    }   
}