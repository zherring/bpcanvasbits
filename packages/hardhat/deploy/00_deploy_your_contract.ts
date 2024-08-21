import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";

const deployYourContract: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployer } = await hre.getNamedAccounts();
  const { deploy } = hre.deployments;

  // Deploy the Test1155 contract
  const nftDeployment = await deploy("BPTestNFT", {
    from: deployer,
    args: [],
    log: true,
  });

  // Deploy the BPCanvasWrapper contract with the address of the Test1155 contract
  const erc20Deployment = await deploy("BPCanvasWrapper", {
    from: deployer,
    args: [nftDeployment.address], // 100 ERC20 tokens per NFT
    log: true,
  });

  console.log("Test1155 deployed to:", nftDeployment.address);
  console.log("BPCanvasWrapper deployed to:", erc20Deployment.address);
};

export default deployYourContract;

deployYourContract.tags = ["BPCanvasWrapper"];
