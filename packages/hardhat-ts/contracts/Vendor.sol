pragma solidity >=0.8.0 <0.9.0;
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import './YourToken.sol';

contract Vendor is Ownable {
  YourToken yourToken;
  uint256 public tokensPerEth = 100;

  // 购买代币事件
  event BuyTokens(address buyer, uint256 amountOfEth, uint256 amountOfTokens);
  event SellTokens(address seller, uint256 amountOfTokens, uint256 amountOfETH);

  constructor(address tokenAddress) public {
    yourToken = YourToken(tokenAddress);
  }

  // 允许用户使用 EHT 购买代币
  function buyTokens() payable public {
    // 检查是否有足够的 ETH
    require(msg.value > 0, "Not enought ether");

    uint256 amountOfTokens = msg.value * tokensPerEth;

    // 检查承销商是否有足够的代币
    uint256 tokenBalance = yourToken.balanceOf(address(this));
    require(tokenBalance > amountOfTokens, "Not enought tokens");
    
    // 发送代币
    bool sent =  yourToken.transfer(msg.sender, amountOfTokens);
    require(sent, "Failed to transfer token to the buyer");

    emit BuyTokens(msg.sender, msg.value, amountOfTokens);
  }

  // 允许所有者取出所有代币
  function withdraw() public onlyOwner {

    uint256 balance = address(this).balance;
    require(balance > 0, "No ether to withdraw");
    
    // 发送代币给所有者
    (bool sent, ) = msg.sender.call{value: balance}("");
    require(sent, "Failed to withdraw balance");
  }
    

  // 允许用户使用代币换回 ETH
  function sellTokens(uint256 amountToSell) public {
    // 价差是否合理
    require(amountToSell > 0, "Amount to sell must be greater than 0");
    
    // 检查用户是否有足够的代币
    uint256 userBalance = yourToken.balanceOf(msg.sender);
    require(userBalance >= amountToSell, "Not enought tokens");

    // 检查承销商是否有足够的 ETH
    uint256 amountOfEthNeeded = amountToSell / tokensPerEth;
    uint256 venderBalance = address(this).balance;
    require(amountOfEthNeeded <= venderBalance, "Not enought ether");

    // 用户发送代币给承销商
    bool sent =  yourToken.transferFrom(msg.sender, address(this), amountToSell);
    require(sent, "Failed to transfer tokens from seller to vender");

    // 承销商发送 ETH 给用户
    (sent, ) = msg.sender.call{value: amountOfEthNeeded}("");
    require(sent, "Failed to send ether from vender to seller");

    emit SellTokens(msg.sender, amountToSell, amountOfEthNeeded);
  }
}
