

export CORE_PEER_TLS_ENABLED=true
export ORDERER_CA=${PWD}/ca/organizations/election_commission/peers/peer0.election_commission/tls/ca.crt
export FABRIC_CFG_PATH=${PWD}/extra/
export CHANNEL_NAME=mychannel

setGlobalsForElectionCommission(){
    export CORE_PEER_LOCALMSPID="ElectionCommissionMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/ca/organizations/election_commission/peers/peer0.election_commission/tls/ca.crt
    export CORE_PEER_MSPCONFIGPATH=${PWD}/ca/organizations/election_commission/users/Admin@election_commission/msp
    export CORE_PEER_ADDRESS=localhost:8051
}

setGlobalsForPeer0MyParty(){
    export CORE_PEER_LOCALMSPID="MyPartyMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/ca/organizations/my_party/peers/peer0.my_party/tls/ca.crt
    export CORE_PEER_MSPCONFIGPATH=${PWD}/ca/organizations/my_party/users/Admin@my_party/msp
    export CORE_PEER_ADDRESS=localhost:7051
}





createChannel(){
    setGlobalsForElectionCommission
	peer channel create -o localhost:7050 -c $CHANNEL_NAME --ordererTLSHostnameOverride orderer.election_commission -f ./artifacts/${CHANNEL_NAME}.tx --outputBlock ./artifacts/${CHANNEL_NAME}.block --tls --cafile $ORDERER_CA
}




joinChannel() {
    setGlobalsForElectionCommission
    peer channel join -b ./artifacts/${CHANNEL_NAME}.block

    setGlobalsForPeer0MyParty
    peer channel join -b ./artifacts/${CHANNEL_NAME}.block

}

updateAnchorPeer() {
    setGlobalsForElectionCommission
    peer channel update -o localhost:7050 --ordererTLSHostnameOverride orderer.election_commission -c $CHANNEL_NAME -f ./artifacts/election_commissionAnchros.tx --tls --cafile $ORDERER_CA

    setGlobalsForPeer0MyParty
    peer channel update -o localhost:7050 --ordererTLSHostnameOverride orderer.election_commission -c $CHANNEL_NAME -f ./artifacts/my_partyAnchors.tx --tls --cafile $ORDERER_CA

}








createChannel
sleep 2
joinChannel
sleep 2
updateAnchorPeer