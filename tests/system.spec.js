const { expect } = require("chai");
const hre = require("hardhat");

describe("Secure Vault System", function () {
  let authManager, vault, owner, recipient;

  before(async () => {
    [owner, recipient] = await ethers.getSigners();

    const AuthorizationManager = await hre.ethers.getContractFactory("AuthorizationManager");
    authManager = await AuthorizationManager.deploy();
    await authManager.deployed();

    const SecureVault = await hre.ethers.getContractFactory("SecureVault");
    vault = await SecureVault.deploy();
    await vault.deployed();
    await vault.initialize(authManager.address);
  });

  describe("Deposits", () => {
    it("Should accept deposits", async () => {
      const depositAmount = hre.ethers.utils.parseEther("1");
      await owner.sendTransaction({
        to: vault.address,
        value: depositAmount
      });
      const balance = await vault.getBalance();
      expect(balance).to.equal(depositAmount);
    });
  });

  describe("Authorizations", () => {
    it("Should prevent reuse of authorization", async () => {
      const authId = hre.ethers.utils.keccak256(hre.ethers.utils.toUtf8Bytes("test-auth-1"));
      const amount = hre.ethers.utils.parseEther("0.5");

      const isConsumed1 = await authManager.isAuthorizationConsumed(authId);
      expect(isConsumed1).to.be.false;

      await authManager.verifyAuthorization(vault.address, recipient.address, amount, authId, "0x");
      const isConsumed2 = await authManager.isAuthorizationConsumed(authId);
      expect(isConsumed2).to.be.true;
    });
  });
});
