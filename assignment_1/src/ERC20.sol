// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

contract ERC20 {
    string tokenName;
    string tokenSymbol;
    uint256 tokenTotalSupply;
    address owner;

    
    constructor(string memory _tokenName, string memory _tokenSymbol, uint256 _initialSupply){
        owner = msg.sender;
        tokenName = _tokenName;
        tokenTotalSupply = _initialSupply;
        tokenSymbol = _tokenSymbol;

         balances[msg.sender] = _initialSupply;
         emit Transfer(address(0), msg.sender, _initialSupply);
    }

   modifier onlyOwner() {
    require(msg.sender == owner, "Only owner can call this function");
    _;
}


    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) private myAllowance;

    function name() public view returns(string memory){
        return tokenName;
    }

    function symbol() public view returns(string memory){
        return tokenSymbol;
    }

    function decimals() public pure returns(uint8){
        return 18;
    }
    
    function totalSupply()public view returns(uint256){
        return tokenTotalSupply;
    }

    function balanceOf(address _owner) public view returns(uint256){
        require((_owner != address(0), "address zero detected"));
        return balances[_owner];
    }


    event Transfer(address indexed owner,  address indexed to, uint256 value);

    function transfer(address _to, uint256 _value)public returns(bool){
        require(_to != address(0), "Address zero detected");
        require(balances[msg.sender] >= _value, "Insufficient funds");
        balances[msg.sender] = balances[msg.sender] - _value;
        balances[_to] = balances[_to] + _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool){
        require(_from != address(0) && _to != address(0), "address zero detected");
        require(_value <= myAllowance[_from][msg.sender], "not approved");
        require(balances[_from] >= _value, "insufficient balance");        
        myAllowance[_from][msg.sender] -= _value;
        balances[_from] -= _value;
        balances[_to] +=  _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

    event Approval(address indexed owner, address indexed spender, uint256 value);

    function approve(address _spender, uint256 _value) public returns (bool){
        require(_spender != address(0), "address zero detected");
        require(_value == 0 || myAllowance[msg.sender][_spender] == 0,"ERC20: must reset allowance to 0 first");
        myAllowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);

        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256){
        return myAllowance[_owner][_spender];
    }


    // this is not part of the erc20 doc but I just feel like adding it
    function mint(address _to, uint256 _value) public onlyOwner{
        require(_to != address(0), "cannot mint to zero address");
        tokenTotalSupply += _value;
        balances[_to] += _value;

        emit Transfer(address(0), _to, _value);
        
    }

    function burn(uint256 _value) public onlyOwner {
    require(balances[msg.sender] >= _value, "Insufficient balance to burn");

    balances[msg.sender] -= _value;
    tokenTotalSupply -= _value; 

    emit Transfer(msg.sender, address(0), _value);
}

}
