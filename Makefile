# Include `.env` file and export its variables
# (`-include` to ignore any errors if it does not exist)
-include .env

# All

all: clean install build

# Install

install:; git submodule update --init --recursive

# Build

build:; forge clean && forge build

# Test

test:; forge clean && forge test
test-with-gas-report:; forge clean && forge test --gas-report
coverage:; forge coverage

# Clean

clean:; forge clean

# Deploy

# The "@" hides the command from your shell 

deploy-mainnet:; forge script script/${file}.s.sol:${contract} --rpc-url ${MAINNET_RPC_URL} --private-key ${DEPLOYER_PRIVATE_KEY} --broadcast --verify --etherscan-api-key ${ETHERSCAN_API_KEY} -vvvv
deploy-goerli:; forge script script/${file}.s.sol:${contract} --rpc-url ${GOERLI_RPC_URL} --private-key ${DEPLOYER_PRIVATE_KEY} --broadcast --verify --etherscan-api-key ${ETHERSCAN_API_KEY} -vvvv
