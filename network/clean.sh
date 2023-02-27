
docker stop election_commission_ca my_party_ca orderer.election_commission orderer2.election_commission orderer3.election_commission peer0.election_commission peer0.my_party
docker rm election_commission_ca my_party_ca orderer.election_commission orderer2.election_commission orderer3.election_commission peer0.election_commission peer0.my_party
docker volume rm -f election_commission_ca my_party_ca docker_orderer2.election_commission docker_orderer.election_commission docker_orderer3.election_commission docker_peer0.election_commission docker_peer0.my_party


sudo rm -rf ./ca/organizations
sudo rm -rf ./ca/server 


sudo rm -rf ./artifacts/genesis.block  ./artifacts/mychannel.tx  ./artifacts/mychannel.block
sudo rm -rf ./artifacts/OrdererMSPanchors.tx ./artifacts/election_commissionAnchros.tx ./artifacts/my_partyAnchors.tx

sudo rm -rf ./connection-profiles/*
sudo rm -rf ../app/wallet/*
sudo rm -rf ../results/*
sudo rm -rf ./log.txt 
sudo rm -rf ../decentralized_voting.tar.gz
# docker system prune 
# docker volume prune 
# docker network rm -f election_test
# clear