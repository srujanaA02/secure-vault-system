#!/bin/bash

set -e

echo "Securing Vault System - Docker Entrypoint"
echo "=========================================="

# Install dependencies
echo "Installing dependencies..."
npm install

# Compile contracts
echo "Compiling smart contracts..."
npm run compile

# Run deployment
echo "Deploying contracts to local blockchain..."
npm run deploy

echo ""
echo "Deployment complete!"
echo "Vault system is ready."

# Keep container running
while true; do
    sleep 1
done
