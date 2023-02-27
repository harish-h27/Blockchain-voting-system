
export CORE_PEER_TLS_ENABLED=true
export ORDERER_CA=${PWD}/ca/organizations/election_commission/orderers/orderer.election_commission/msp/tlscacerts/tlsca.election_commission-cert.pem
export FABRIC_CFG_PATH=${PWD}/extra/
export CHANNEL_NAME=mychannel
export PEER0_my_party_ca=${PWD}/ca/organizations/my_party/peers/peer0.my_party/tls/ca.crt
export PEER0_election_commission_ca=${PWD}/ca/organizations/election_commission/peers/peer0.election_commission/tls/ca.crt
setGlobalsForPeer0ElectionCommission(){
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




# presetup

CHANNEL_NAME="mychannel"
CC_RUNTIME_LANGUAGE="node"
VERSION="1"
SEQUENCE="1"
CC_SRC_PATH="../chaincode"
CC_NAME="decentralized_voting"

packageChaincode() {
    rm -rf ../${CC_NAME}.tar.gz
    setGlobalsForPeer0MyParty
    peer lifecycle chaincode package ../${CC_NAME}.tar.gz \
        --path ${CC_SRC_PATH} --lang ${CC_RUNTIME_LANGUAGE} \
        --label ${CC_NAME}_${VERSION}
    echo "===================== Chaincode is packaged ===================== "
}

installChaincode() {
    setGlobalsForPeer0MyParty
    peer lifecycle chaincode install ../${CC_NAME}.tar.gz
    echo "===================== Chaincode is installed on peer0.org1 ===================== "

    setGlobalsForPeer0ElectionCommission
    peer lifecycle chaincode install ../${CC_NAME}.tar.gz
    echo "===================== Chaincode is installed on peer0.ordererOrg ===================== "
}

queryInstalled() {
    setGlobalsForPeer0MyParty
    peer lifecycle chaincode queryinstalled >&log.txt
    cat log.txt
    PACKAGE_ID=$(sed -n "/${CC_NAME}_${VERSION}/{s/^Package ID: //; s/, Label:.*$//; p;}" log.txt)
    echo PackageID is ${PACKAGE_ID}
    echo "===================== Query installed successful on peer0.org1 on channel ===================== "
}

approveForMyParty() {
    setGlobalsForPeer0MyParty
    set -x
    peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.election_commission --tls --cafile $ORDERER_CA --channelID $CHANNEL_NAME --name ${CC_NAME} --version ${VERSION} --sequence ${SEQUENCE} --init-required --package-id ${PACKAGE_ID} 
    set +x

    echo "===================== chaincode approved from org 1 ===================== "

}


checkCommitReadyness1() {
    setGlobalsForPeer0MyParty
    peer lifecycle chaincode checkcommitreadiness \
        --channelID $CHANNEL_NAME --name ${CC_NAME} --version ${VERSION} \
        --sequence ${SEQUENCE} --output json --init-required
    echo "===================== checking commit readyness from org 1 ===================== "
}




approveForElectionCommission() {
    setGlobalsForPeer0ElectionCommission

    peer lifecycle chaincode approveformyorg -o localhost:7050 \
        --ordererTLSHostnameOverride orderer.election_commission --tls $CORE_PEER_TLS_ENABLED \
        --cafile $ORDERER_CA --channelID $CHANNEL_NAME --name ${CC_NAME} \
        --version ${VERSION} --init-required --package-id ${PACKAGE_ID} \
        --sequence ${SEQUENCE}

    echo "===================== chaincode approved from org 2 ===================== "
}



checkCommitReadyness3() {

    setGlobalsForPeer0ElectionCommission
    peer lifecycle chaincode checkcommitreadiness --channelID $CHANNEL_NAME \
        --peerAddresses localhost:8051 --tlsRootCertFiles $PEER0_election_commission_ca \
        --name ${CC_NAME} --version ${VERSION} --sequence ${SEQUENCE} --output json --init-required
    echo "===================== checking commit readyness from org 1 ===================== "
}



commitChaincodeDefination() {
    setGlobalsForPeer0MyParty
    peer lifecycle chaincode commit -o localhost:7050 --ordererTLSHostnameOverride orderer.election_commission \
        --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA \
        --channelID $CHANNEL_NAME --name ${CC_NAME} \
        --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_my_party_ca \
        --peerAddresses localhost:8051 --tlsRootCertFiles $PEER0_election_commission_ca \
        --version ${VERSION} --sequence ${SEQUENCE} --init-required

}


queryCommitted() {
    setGlobalsForPeer0MyParty
    peer lifecycle chaincode querycommitted --channelID $CHANNEL_NAME --name ${CC_NAME}

}


chaincodeInvokeInit() {
        #     // electionStart and end time must be passed like this "DD-MM-YYYY HH:MM:SS"
        # const [ chiefName, chiefAadharNumber, electionStartTimeStamp, electionEndTimeStamp] = params;
    setGlobalsForPeer0MyParty
    fcn_call='{"function":"initLedger","Args":["HarishH","4909-0261-4657","19-12-2022-09:30:00","22-12-2022-18:00:00"]}'
    peer chaincode invoke -o localhost:7050 \
        --ordererTLSHostnameOverride orderer.election_commission \
        --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA \
        -C $CHANNEL_NAME -n ${CC_NAME} \
        --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_my_party_ca \
        --peerAddresses localhost:8051 --tlsRootCertFiles $PEER0_election_commission_ca \
        --isInit -c $fcn_call

}



chaincodeInvoke() {
    setGlobalsForPeer0MyParty
    
    # Create Car
    peer chaincode invoke -o localhost:7050 \
        --ordererTLSHostnameOverride orderer.election_commission \
        --tls $CORE_PEER_TLS_ENABLED \
        --cafile $ORDERER_CA \
        -C $CHANNEL_NAME -n ${CC_NAME}  \
        --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_my_party_ca \
        --peerAddresses localhost:8051 --tlsRootCertFiles $PEER0_election_commission_ca \
        -c '{"function": "createCar","Args":["harishxmb", "harish", "harish", "harish", "harish"]}'

}


chaincodeInvokeDeleteAsset() {
    setGlobalsForPeer0MyParty

    # Create Car
    peer chaincode invoke -o localhost:7050 \
        --ordererTLSHostnameOverride orderer.election_commission \
        --tls $CORE_PEER_TLS_ENABLED \
        --cafile $ORDERER_CA \
        -C $CHANNEL_NAME -n ${CC_NAME}  \
        --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_my_party_ca \
        -c '{"function": "DeleteCarById","Args":["2"]}'

}


chaincodeQuery() {
    setGlobalsForPeer0MyParty
    # setGlobalsForOrg1
    peer chaincode query -C $CHANNEL_NAME -n ${CC_NAME} -c '{"function": "queryCar","Args":["harishxmb"]}'
}


packageChaincode
installChaincode
queryInstalled

approveForMyParty
checkCommitReadyness1

approveForElectionCommission
checkCommitReadyness3


sleep 5
commitChaincodeDefination
sleep 5
queryCommitted
sleep 5
chaincodeInvokeInit























# chaincodeInvoke
# sleep 10
# chaincodeQuery
