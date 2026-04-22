-include .env
deploy:;forge script script/Deploy.s.sol --broadcast  --rpc-url $(SEPOLIA_RPC_URL) --verify --etherscan-api-key $(ETHERSCAN_API_KEY) --account deployer
send:;cast send $(CONTRACT_ADDRESS) "transfer(address,uint256)"  --rpc-url $(SEPOLIA_RPC_URL) --account deployer