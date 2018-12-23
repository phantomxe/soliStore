pragma solidity ^0.4.22;

import "browser/Store.sol";

contract StoreCart is Store{
    address public customerAddress;
    string private customerFullName;
    string private customerShipAddress;
    string private customerTelephone;
    
    Item[] private cartItems; 
    uint256 private cartTotalPrice;
    
    function StoreCart()
    {
        customerAddress = msg.sender; 
        cartTotalPrice = 0;
    }
     
    function() payable {
    }
    
    modifier canAddItem{
        require(msg.sender == customerAddress);
        _;
    }
    
    function addItem(bytes32 id, uint256 amount) canAddItem returns(bool success, uint256 currentPayout) {
        var _item = items[id];
        if(_item.quantity - amount < 0)
            return (false, cartTotalPrice);
        
        _item.quantity = amount;
        items[id].quantity -= amount;
        
        cartItems.push(_item);  
        cartTotalPrice += _item.quantity * _item.price;
        
        return (true, cartTotalPrice);
    }
    
    function removeItem(bytes32 id) canAddItem returns(bool success, uint256 currentPayout) {
        var _item = items[id];
        
        for(uint256 i = 0; i < cartItems.length; i++)
        {
            if(cartItems[i].id == _item.id)
            {
                cartTotalPrice -= cartItems[i].quantity * cartItems[i].price;
                 
                delete cartItems[i];
                return (true, cartTotalPrice);
            }
        }
            
        return (false, cartTotalPrice);
    }
    
}
