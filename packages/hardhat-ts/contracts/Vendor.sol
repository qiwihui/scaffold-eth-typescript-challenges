pragma solidity >=0.8.0 <0.9.0;
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import './YourToken.sol';

contract Vendor is Ownable {
  YourToken yourToken;
  uint256 public tokensPerEth = 100;

  // 购买代币事件
  event BuyTokens(address buyer, uint256 amountOfEth, uint256 amountOfTokens);

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
    

  // ToDo: create a sellTokens() function:
}
