pragma solidity ^0.5.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/SupplyChain.sol";

contract TestSupplyChain {
    uint value = 100 ether;

    SupplyChain myContract;

    function() external payable {}

    function beforeEach() public {
        myContract = new SupplyChain();
        myContract.addItem('testItem', value);
    }

    // Test for failing conditions in this contracts:
    // https://truffleframework.com/tutorials/testing-for-throws-in-solidity-tests

    // buyItem
    function BuyandPay(uint sku) internal pure returns (bytes memory) {
        return abi.encodeWithSignature("buyItem(uint256)", sku);
    }
    // test for failure if user does not send enough funds
    function IfUserDoesNotSendEnoughFunds() public {
        myContract.addItem("item1", 2 ether);
        uint sku = 0;
        bool success;

        (success, ) = address(myContract).call.value(1 ether)(BuyandPay(sku));

        Assert.isFalse(success, "Should fail when transfering less amount of ether than is the price");
    }
    // test for purchasing an item that is not for Sale
    function IfItemIsNotForSale() public {
        uint sku = 1;
        bool success;

        (success, ) = address(myContract).call.value(1 ether)(BuyandPay(sku));

        Assert.isFalse(success, "Should fail when purchasing an item which does not exist");
    }
    // shipItem
    function CallsThatAreMadeByNotTheSeller() public {
        myContract.addItem("item1", 0 ether);
        uint sku = 0;
        myContract.buyItem(sku);
        bool success;

        (success, ) = address(0).call(abi.encodeWithSignature("shipItem(address,uint256)", address(myContract), sku));

        Assert.isFalse(success, "Should fail when sender is not seller");
    }
    // test for calls that are made by not the seller

    function TryingToShipAnItemThatIsNotMarkedSold() public {
        uint sku = 0;
        bool success;

        (success, ) = address(myContract).call(abi.encodeWithSignature("shipItem(uint256)", sku));

        Assert.isFalse(success, "Should fail when shipping item which is not sold");
    }
    // test for trying to ship an item that is not marked Sold

    // receiveItem
    function ReceiveandPay(uint sku) internal pure returns (bytes memory) {
        return abi.encodeWithSignature("receiveItem(uint256)", sku);
    }
    // test calling the function from an address that is not the buyer
    function CallingTheFunctionFromAnAddressThatIsNotTheBuyer() public {
        myContract.addItem("item1", 0 ether);
        uint sku = 0;
        myContract.buyItem(sku);
        myContract.shipItem(sku);
        bool success;

        (success, ) = address(0).call(abi.encodeWithSignature("receiveItem(address,uint256)", address(myContract), sku));

        Assert.isFalse(success, "Should fail when sender is not buyer");
    }
    // test calling the function on an item not marked Shipped
    function CallingTheFunctionOnAnItemNotMarkedShipped() public {
        uint sku = 0;
        bool success;

        (success, ) = address(0).call(abi.encodeWithSignature("receiveItem(address,uint256)", address(myContract), sku));

        Assert.isFalse(success, "Should fail when receiving item which is not shipped");
    }

}
