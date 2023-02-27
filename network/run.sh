docker-compose -f ./docker/docker-compose-ca.yaml up -d

sleep 5
./scripts/createCertificates.sh 



echo "####create artifacts####"
./scripts/createArtifacts.sh



docker-compose -f ./docker/docker-compose-network.yaml up -d
sleep 5




echo "####channel oparations####"
./scripts/createChannel.sh 
sleep 5 


cd ../chaincode/
npm i 
cd ../network
echo "####chaincode oparations####"
./scripts/deployChaincode.sh



echo "####generating connection profiles####"
./scripts/generateCcp.sh


cd ../app 
npm i
npm run build 
node dist/index.js