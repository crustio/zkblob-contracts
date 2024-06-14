include .env

deploy-zkblob:
	forge script script/ZkBlob.s.sol:ZkBlobScript --private-key ${PRIVATE_KEY} --broadcast --rpc-url ${RPC_URL} --legacy --verify --etherscan-api-key ${ETHERSCAN_API_KEY}

deploy-das:
	forge script script/DAS.s.sol:DASScript --private-key ${PRIVATE_KEY} --broadcast --rpc-url ${RPC_URL} --legacy --verify --etherscan-api-key ${ETHERSCAN_API_KEY}
