pragma solidity ^0.4.22;

contract Store{
    string public storeName; 
    uint256 private storeBalance; 
    address public storeAddress;
    
    mapping (bytes32 => Item) public items; 
    bytes32[] private itemsIdList;
    
    ReservedCart[] private customerReserverd;
    
    struct ReservedCart{
        address customer;
        ReservedItem[] itemsList;
    }
    
    struct ReservedItem {
        bytes32 id;
        uint256 amount;
    }
    
    function Store() {
        storeAddress = msg.sender;
        storeName = "MyStore";
        storeBalance = 0;
        if (this.balance > 0) throw;
    }
    
    modifier onlyOwner{
        require(msg.sender == storeAddress);
        _;
    }
    
    modifier onlyBuyer{
        require(msg.sender != storeAddress);
        _;
    }
    
    function() payable {
        
    }
    
    struct Item{
        bytes32 id;
        uint256 quantity; 
        uint256 price;
        string name;
        string basicDescription;
        string notes;
    }
    
    function reserveItem(bytes32 id, uint256 amount, address customer) onlyBuyer returns(bool success) {
        for(uint256 i = 0; i < itemsIdList.length; i++)
        {
            if(itemsIdList[i] == id && items[id].quantity >= amount)
            { 
                var it = ReservedItem(id, amount); //Create new reserved item
                
                for(var j = 0; j < customerReserverd.length; j++)
                { 
                    if(customerReserverd[j].customer ==  msg.sender) //If customer in the store before, only append new item
                    {
                        for(var s = 0; s < customerReserverd[j].itemsList.length; s++)
                        {
                            if(customerReserverd[j].itemsList[s].id == id)
                            {
                                items[id].quantity += customerReserverd[j].itemsList[s].amount; // Recover old data in item database
                                items[id].quantity -= amount;                                   // Write new data in item database
                                
                                customerReserverd[j].itemsList[s].amount = amount; // Apply reserved amout;
                                return true;
                            }
                        }
                        //Customer never get this item before
                        customerReserverd[j].itemsList.push(it);
                        items[id].quantity -= amount; 
                        return true;
                    } 
                }
                
                //New customer in this store
                ReservedItem[] arr;
                arr.push(it);
                var cart = ReservedCart(msg.sender, arr); 
                customerReserverd.push(cart);
                items[id].quantity -= amount; 
                
                return true;
            }
        }
        return false;
    }
    
    function registerItem(bytes32 id, uint256 quantity, uint256 price, string name,
                          string basicDescription, string notes)
                        onlyOwner returns(bool) {
        var newItem = Item(id, quantity, price, name, basicDescription, notes);
        if(price > 0)
        {
            items[id] = newItem;
            itemsIdList.push(id);
            return true;
        }
              
        return false;              
    }
    
    function getItem(bytes32 id) public returns(bool success, string name, string desc, uint256 availableAmount, uint256 price) {
        var _item = items[id];                
        if(_item.id == id)
        {
            return (true, _item.name, _item.basicDescription, _item.quantity, _item.price);
        }
        return (false, "", "", 0, 0);
    }
    
    function getItems() public returns(bytes32[] ids)
    {
        return itemsIdList;
    }
    
    function deregisterItem(bytes32 id)
                        onlyOwner returns(bool) {
        var _item = items[id];                
        if(_item.id == id)
        {
            delete items[id];
            for(uint256 i = 0; i < itemsIdList.length; i++)
            {
                if(itemsIdList[i] == id)
                {
                    delete itemsIdList[i];
                    return true;
                }
            }
            return false;
        }
              
        return false;              
    }
}
