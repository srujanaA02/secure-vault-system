// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./AuthorizationManager.sol";

contract SecureVault {
    AuthorizationManager public authorizationManager;
    uint256 public totalBalance;
    bool private initialized;
    
    event Deposit(address indexed depositor, uint256 amount);
    event Withdrawal(address indexed recipient, uint256 amount, bytes32 indexed authId);
    event AuthorizationVerified(bytes32 indexed authId);
    
    modifier onceInitialized() {
        require(!initialized, "Already initialized");
        initialized = true;
        _;
    }
    
    /**
     * @notice Initialize the vault with an authorization manager
     */
    function initialize(address authManager) external onceInitialized {
        require(authManager != address(0), "Invalid authorization manager");
        authorizationManager = AuthorizationManager(authManager);
    }
    
    /**
     * @notice Accept deposits of native currency
     */
    receive() external payable {
        totalBalance += msg.value;
        emit Deposit(msg.sender, msg.value);
    }
    
    /**
     * @notice Withdraw funds with authorization
     */
    function withdraw(
        address payable recipient,
        uint256 amount,
        bytes32 authId,
        bytes calldata signature
    ) external {
        require(recipient != address(0), "Invalid recipient");
        require(amount > 0, "Amount must be greater than 0");
        require(totalBalance >= amount, "Insufficient balance");
        
        // Verify authorization with the authorization manager
        bool isAuthorized = authorizationManager.verifyAuthorization(
            address(this),
            recipient,
            amount,
            authId,
            signature
        );
        
        require(isAuthorized, "Authorization failed");
        
        // Update balance before transferring (state before value)
        totalBalance -= amount;
        
        emit AuthorizationVerified(authId);
        
        // Transfer funds
        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Transfer failed");
        
        emit Withdrawal(recipient, amount, authId);
    }
    
    /**
     * @notice Get current vault balance
     */
    function getBalance() external view returns (uint256) {
        return totalBalance;
    }
    
    /**
     * @notice Check if a specific authorization has been consumed
     */
    function isAuthorizationConsumed(bytes32 authId) external view returns (bool) {
        return authorizationManager.isAuthorizationConsumed(authId);
    }
}
