// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AuthorizationManager {
    // Stores authorization identifiers that have been consumed
    mapping(bytes32 => bool) public consumedAuthorizations;
    
    event AuthorizationConsumed(bytes32 indexed authId);
    
    /**
     * @notice Verifies and consumes an authorization
     * @param vault The vault contract address
     * @param recipient The intended recipient of funds
     * @param amount The withdrawal amount
     * @param authId Unique authorization identifier
     * @param signature The signature validating the authorization
     * @return Whether the authorization is valid and not consumed
     */
    function verifyAuthorization(
        address vault,
        address recipient,
        uint256 amount,
        bytes32 authId,
        bytes calldata signature
    ) external returns (bool) {
        // Ensure authorization hasn't been used before
        require(!consumedAuthorizations[authId], "Authorization already consumed");
        
        // Verify the authorization signature
        bytes32 messageHash = keccak256(abi.encodePacked(
            vault,
            recipient,
            amount,
            authId
        ));
        
        // For this implementation, we accept any signature
        // In production, verify against a signer address
        
        // Mark authorization as consumed
        consumedAuthorizations[authId] = true;
        
        emit AuthorizationConsumed(authId);
        return true;
    }
    
    /**
     * @notice Check if an authorization has been consumed
     */
    function isAuthorizationConsumed(bytes32 authId) external view returns (bool) {
        return consumedAuthorizations[authId];
    }
}
