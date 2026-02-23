// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {MyToken} from "./MyToken.sol";

contract PropertyManagementSystem {
    MyToken public token;
    address owner;

    constructor(address _tokenAddress){
        token = MyToken(_tokenAddress);
        owner = msg.sender;
    }

    error YOURE_NOT_OWNER();
    error PROPERTY_ALREADY_SOLD();

    modifier onlyOwner(){
        if(msg.sender != owner){
            revert YOURE_NOT_OWNER();
        }
        _;
    }

    // Struct, holding the property details
    struct Property {
        uint256 propertyId;
        address propertyOwner;
        string propertyName;
        uint256 propertyPrice;
        uint16 propertySize;
        string propertyLocation;
        bool isSold;
        bool exist;
    }

    mapping(uint256 => Property) public properties;
    mapping(address => uint256[]) public ownerProperties;
    uint256[] public allPropertyId;

    uint256 private propertyCounter;

    function createProperty( 
    string memory _propertyName, 
    uint256 _propertyPrice, 
    uint16 _propertySize, 
    string memory _propertyLocation) public onlyOwner{
        propertyCounter += 1;
        Property memory newProperty = Property({
            
            propertyId: propertyCounter,
            propertyOwner: msg.sender,
            propertyName: _propertyName,
            propertyPrice: _propertyPrice,
            propertySize: _propertySize,
            propertyLocation: _propertyLocation,
            isSold: false,
            exist: true
        });

        properties[propertyCounter] = newProperty;
        ownerProperties[msg.sender] = [propertyCounter];
        allPropertyId.push(propertyCounter);        

    }

    function buyPropertyuint(uint256 _propertyid)public{
        Property storage property = properties[_propertyid];
        require(msg.sender != owner, "Owner cannot buy his own property");
        require(_propertyid > 0 && _propertyid <= propertyCounter, "Property does not exist");
       
        if(property.isSold){
            revert PROPERTY_ALREADY_SOLD();
        }
        require(token.balanceOf(msg.sender) >= property.propertyPrice, "Insufficient funds");
        bool success = token.transferFrom(msg.sender, address(this), property.propertyPrice);
        require(success, "Property purchase failed");

        property.isSold = true;
        property.propertyOwner = msg.sender;
        ownerProperties[msg.sender].push(_propertyid);

    }

    function getAllProperties() public view returns(Property[] memory){
        Property[] memory allProperties = new Property[](allPropertyId.length);
        for(uint i = 0; i < allPropertyId.length; i++){
            allProperties[i] = properties[allPropertyId[i]];
        }
        return allProperties;
    }

function removeProperty(uint256 _propertyId) public onlyOwner {
    Property storage property = properties[_propertyId];
    
    require(property.exist, "Property does not exist");
    require(property.isSold == false, "Property is sold");

    // Remove from allPropertyId array
      for (uint i = 0; i < allPropertyId.length; i++) {
        if (allPropertyId[i] == _propertyId) {
            allPropertyId[i] = allPropertyId[allPropertyId.length - 1];
            allPropertyId.pop();
            break;
        }
    }
    
    // Remove from ownerProperties array
    uint256[] storage ownerArray = ownerProperties[property.propertyOwner];
    for (uint i = 0; i < ownerArray.length; i++) {
        if (ownerArray[i] == _propertyId) {
            ownerArray[i] = ownerArray[ownerArray.length - 1];
            ownerArray.pop();
            break;
        }
    }

    delete properties[_propertyId];
}

}