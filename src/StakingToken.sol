// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract StakingToken {

    string public constant name = "RanToken";
    string public constant symbol = "RT";
    uint8 public constant decimals = 18;
    uint256 public totalSupply;

    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowances;
    mapping(address => uint256) stakedBalance;
    mapping(address => uint) stakeTime;
    mapping(address => bool) stakeStatus;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Burn(address indexed from, uint256 value);
    event Mint(address indexed to, uint256 value);
    event Stake(address indexed from, uint256 value);
    event Unstake(address indexed from, uint256 value);

    error StakingToken__StakeBalanceMustNotBeZero();

    constructor(uint256 initialSupply) {
        balances[msg.sender] = initialSupply;
        totalSupply = initialSupply;
    }

    function balanceOf(address owner) public view returns (uint256) {
        return balances[owner];
    }

    function transfer(address to, uint256 value) public returns (bool) {
        require(balances[msg.sender] >= value);
        balances[msg.sender] -= value;
        balances[to] += value;
        emit Transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        require(balances[from] >= value && allowances[from][msg.sender] >= value);
        balances[from] -= value; 
        balances[to] += value; 
        allowances[from][msg.sender] -= value; 
        emit Transfer(from, to, value); 
        return true;
    }

    function approve(address spender, uint256 value) public returns (bool) {
        allowances[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return allowances[owner][spender];
    }

    function burn(address from, uint256 value) public {
        require(balances[from] >= value, "Insufficient balance!");
        balances[from] -= value;
        totalSupply -= value;
        emit Burn(from, value);
    }

    function mint(address to, uint256 value) public {
        totalSupply += value;
        balances[to] += value;
        emit Mint(to, value);
    }

    function stake(uint256 value) public {
        require(value > 0, "Amount must be higher than 0");
        require(balances[msg.sender] >= value, "Insufficient balance");
        balances[msg.sender] -= value;
        stakedBalance[msg.sender] += value;
        stakeStatus[msg.sender] = true;
        stakeTime[msg.sender] = block.timestamp;
        emit Stake(msg.sender, value);        
    }

    function unstake() public {
        if (stakedBalance[msg.sender] == 0) {
            revert StakingToken__StakeBalanceMustNotBeZero();
        }
        uint256 timePassed = block.timestamp - stakeTime[msg.sender];
        uint256 initialStakeAmount = stakedBalance[msg.sender];
        uint256 bonusAmount = initialStakeAmount + (initialStakeAmount * 20 / 100);
        uint256 burnAmount = initialStakeAmount - (initialStakeAmount * 20 / 100);
        uint256 amountToReturnAfterStakingFor30DaysOrMore = initialStakeAmount + bonusAmount;
        uint256 amountToReturnAfterStakingForLessThan30Days = initialStakeAmount - burnAmount;
        if (timePassed < 30 days) {
            transfer(msg.sender, amountToReturnAfterStakingForLessThan30Days);
        } else {   
            transfer(msg.sender, amountToReturnAfterStakingFor30DaysOrMore);
        }
        stakedBalance[msg.sender] = 0;
        stakeStatus[msg.sender] = false;
        emit Unstake(msg.sender, initialStakeAmount);       
    } 

    function getStakedBalance(address _address) external view returns(uint) {
        return stakedBalance[_address];
    }

    function getStakeStatus(address _address) external view returns(bool) {
        return stakedBalance[_address] > 0;
    }

}