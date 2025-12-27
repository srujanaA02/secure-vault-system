const hre = require("hardhat");
const fs = require("fs");

async function main() {
  console.log("Starting deployment...");

  // Deploy AuthorizationManager
  console.log("Deploying AuthorizationManager...");
  const AuthorizationManager = await hre.ethers.getContractFactory("AuthorizationManager");
  const authManager = await AuthorizationManager.deploy();
  await authManager.deployed();
  console.log("AuthorizationManager deployed to:", authManager.address);

  // Deploy SecureVault
  console.log("Deploying SecureVault...");
  const SecureVault = await hre.ethers.getContractFactory("SecureVault");
  const vault = await SecureVault.deploy();
  await vault.deployed();
  console.log("SecureVault deployed to:", vault.address);

  // Initialize vault with authorization manager
  console.log("Initializing vault...");
  await vault.initialize(authManager.address);
  console.log("Vault initialized with AuthorizationManager");

  // Get network info
  const network = await hre.ethers.provider.getNetwork();
  console.log("Network Chain ID:", network.chainId);

  // Save deployment info
  const deploymentInfo = {
    network: network.chainId,
    authorizationManager: authManager.address,
    vault: vault.address,
    timestamp: new Date().toISOString()
  };

  // Save to file
  const outputPath = "./deployment-info.json";
  fs.writeFileSync(outputPath, JSON.stringify(deploymentInfo, null, 2));
  console.log("\nDeployment info saved to", outputPath);
  console.log(JSON.stringify(deploymentInfo, null, 2));
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
