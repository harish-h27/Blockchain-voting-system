
export FABRIC_CFG_PATH=${PWD}/config


echo "genesis block creation tx file"
configtxgen -outputBlock ${PWD}/artifacts/genesis.block -profile TwoOrgsOrdererGenesis -channelID system-channel 



echo "channel creation tx file"
configtxgen -outputCreateChannelTx ./artifacts/mychannel.tx -profile TwoOrgsChannel -channelID mychannel



echo "Anchor Peer tx files"
configtxgen -outputAnchorPeersUpdate ./artifacts/election_commissionAnchros.tx -profile TwoOrgsChannel -channelID mychannel -asOrg ElectionCommissionMSP

configtxgen -outputAnchorPeersUpdate ./artifacts/my_partyAnchors.tx -profile TwoOrgsChannel -channelID mychannel -asOrg MyPartyMSP

