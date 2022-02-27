import { DeployFunction } from 'hardhat-deploy/types';
import { parseEther } from 'ethers/lib/utils';
import { HardhatRuntimeEnvironmentExtended } from 'helpers/types/hardhat-type-extensions';
import { ethers } from 'hardhat';

const func: DeployFunction = async (hre: HardhatRuntimeEnvironmentExtended) => {
  const { getNamedAccounts, deployments } = hre as any;
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  // You might need the previously deployed yourToken:
  const yourToken = await ethers.getContract('YourToken', deployer);

  // 部署承销商
  await deploy('Vendor', {
    // Learn more about args here: https://www.npmjs.com/package/hardhat-deploy#deploymentsdeploy
    from: deployer,
    args: [yourToken.address],
    log: true,
  });

  // 获取承销商合约
  const vendor = await ethers.getContract('Vendor', deployer);

  // 发送 1000 个代币给承销商
  console.log('\n 🏵  Sending all 1000 tokens to the vendor...\n');
  await yourToken.transfer(vendor.address, ethers.utils.parseEther('1000'));

  // 转移所有权
  await vendor.transferOwnership('0x169841AA3024cfa570024Eb7Dd6Bf5f774092088');
};
export default func;
func.tags = ['Vendor'];
