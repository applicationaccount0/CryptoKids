// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CryptoKids {
    address private owner;

    modifier onlyOwner() {
        require(msg.sender == owner, "only the owner can add kids");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    struct kid {
        address payable WalletAdress;
        string firstName;
        string secondName;
        uint256 releaseTime;
        uint256 amount;
        bool canWithdraw;
    }

    kid[] public kids;

    function addKids(
        address payable WalletAdress,
        string memory firstName,
        string memory secondName,
        uint256 releaseTime,
        uint256 amount,
        bool canWithdraw
    ) public onlyOwner {
        kids.push(kid(WalletAdress, firstName, secondName, releaseTime, amount, canWithdraw));
    }

    function balanceOf() public view returns (uint256) {
        return address(this).balance;
    }

    function addTokidsBalance(address WalletAdress) private {
        require(kids.length > 0, "No kids found to deposit");
        for (uint i = 0; i < kids.length; i++) {
            if (kids[i].WalletAdress == WalletAdress) {
                kids[i].amount += msg.value;
            }
        }
    }

    function deposit(address WalletAdress) payable public {
        addTokidsBalance(WalletAdress);
        emit FundsDeposited(WalletAdress, msg.value);
    }

    function getIndex(address payable WalletAdress) view private returns (uint256) {
        for (uint i = 0; i < kids.length; i++) {
            if (kids[i].WalletAdress == WalletAdress) {
                return i;
            }
        }
        revert("Kid not found");
    }

    function availableToWithdraw(address payable WalletAdress) public returns (bool) {
        uint256 i = getIndex(WalletAdress);
        require(block.timestamp > kids[i].releaseTime, "You cannot withdraw yet");
        kids[i].canWithdraw = true;
        return true;
    }

    function withdraw(address payable WalletAdress) public {
        uint256 i = getIndex(WalletAdress);
        require(msg.sender == kids[i].WalletAdress, "You must be the kid to withdraw");
        require(kids[i].canWithdraw, "You cannot withdraw at this time");
        uint256 amount = kids[i].amount;
        kids[i].WalletAdress.transfer(amount);
        kids[i].amount = 0;
        emit FundsWithdrawn(WalletAdress, amount);
    }

    event FundsDeposited(address indexed WalletAdress, uint256 amount);
    event FundsWithdrawn(address indexed WalletAdress, uint256 amount);
}
