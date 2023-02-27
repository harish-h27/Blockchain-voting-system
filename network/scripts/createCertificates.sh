#!/bin/bash
function infoln() {
  echo
  echo $1 
  echo 
}



function createElectionCommission() {
  infoln "Enrolling the CA admin"
  mkdir -p ./ca/organizations/election_commission

  export FABRIC_CA_CLIENT_HOME=${PWD}/ca/organizations/election_commission

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:9054 --caname election_commission_ca --tls.certfiles ${PWD}/ca/server/election_commission/tls-cert.pem
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-9054-election_commission_ca.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-9054-election_commission_ca.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-9054-election_commission_ca.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-9054-election_commission_ca.pem
    OrganizationalUnitIdentifier: orderer' >${PWD}/ca/organizations/election_commission/msp/config.yaml

  infoln "Registering orderer"
  set -x
  fabric-ca-client register --caname election_commission_ca --id.name orderer --id.secret ordererpw --id.type orderer --tls.certfiles ${PWD}/ca/server/election_commission/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Registering the orderer admin"
  set -x
  fabric-ca-client register --caname election_commission_ca --id.name ordererAdmin --id.secret ordererAdminpw --id.type admin --tls.certfiles ${PWD}/ca/server/election_commission/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Generating the orderer msp"
  set -x
  fabric-ca-client enroll -u https://orderer:ordererpw@localhost:9054 --caname election_commission_ca -M ${PWD}/ca/organizations/election_commission/orderers/orderer.election_commission/msp --csr.hosts orderer.election_commission --csr.hosts localhost --tls.certfiles ${PWD}/ca/server/election_commission/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/ca/organizations/election_commission/msp/config.yaml ${PWD}/ca/organizations/election_commission/orderers/orderer.election_commission/msp/config.yaml

  infoln "Generating the orderer-tls certificates"
  set -x
  fabric-ca-client enroll -u https://orderer:ordererpw@localhost:9054 --caname election_commission_ca -M ${PWD}/ca/organizations/election_commission/orderers/orderer.election_commission/tls --enrollment.profile tls --csr.hosts orderer.election_commission --csr.hosts localhost --tls.certfiles ${PWD}/ca/server/election_commission/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/ca/organizations/election_commission/orderers/orderer.election_commission/tls/tlscacerts/* ${PWD}/ca/organizations/election_commission/orderers/orderer.election_commission/tls/ca.crt
  cp ${PWD}/ca/organizations/election_commission/orderers/orderer.election_commission/tls/signcerts/* ${PWD}/ca/organizations/election_commission/orderers/orderer.election_commission/tls/server.crt
  cp ${PWD}/ca/organizations/election_commission/orderers/orderer.election_commission/tls/keystore/* ${PWD}/ca/organizations/election_commission/orderers/orderer.election_commission/tls/server.key

  mkdir -p ${PWD}/ca/organizations/election_commission/orderers/orderer.election_commission/msp/tlscacerts
  cp ${PWD}/ca/organizations/election_commission/orderers/orderer.election_commission/tls/tlscacerts/* ${PWD}/ca/organizations/election_commission/orderers/orderer.election_commission/msp/tlscacerts/tlsca.election_commission-cert.pem

  mkdir -p ${PWD}/ca/organizations/election_commission/msp/tlscacerts
  cp ${PWD}/ca/organizations/election_commission/orderers/orderer.election_commission/tls/tlscacerts/* ${PWD}/ca/organizations/election_commission/msp/tlscacerts/tlsca.election_commission-cert.pem









  infoln "Registering orderer"
  set -x
  fabric-ca-client register --caname election_commission_ca --id.name orderer2 --id.secret ordererpw --id.type orderer --tls.certfiles ${PWD}/ca/server/election_commission/tls-cert.pem
  { set +x; } 2>/dev/null




  infoln "Generating the orderer msp"
  set -x
  fabric-ca-client enroll -u https://orderer2:ordererpw@localhost:9054 --caname election_commission_ca -M ${PWD}/ca/organizations/election_commission/orderers/orderer2.election_commission/msp --csr.hosts orderer2.election_commission --csr.hosts localhost --tls.certfiles ${PWD}/ca/server/election_commission/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/ca/organizations/election_commission/msp/config.yaml ${PWD}/ca/organizations/election_commission/orderers/orderer2.election_commission/msp/config.yaml

  infoln "Generating the orderer-tls certificates"
  set -x
  fabric-ca-client enroll -u https://orderer2:ordererpw@localhost:9054 --caname election_commission_ca -M ${PWD}/ca/organizations/election_commission/orderers/orderer2.election_commission/tls --enrollment.profile tls --csr.hosts orderer2.election_commission --csr.hosts localhost --tls.certfiles ${PWD}/ca/server/election_commission/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/ca/organizations/election_commission/orderers/orderer2.election_commission/tls/tlscacerts/* ${PWD}/ca/organizations/election_commission/orderers/orderer2.election_commission/tls/ca.crt
  cp ${PWD}/ca/organizations/election_commission/orderers/orderer2.election_commission/tls/signcerts/* ${PWD}/ca/organizations/election_commission/orderers/orderer2.election_commission/tls/server.crt
  cp ${PWD}/ca/organizations/election_commission/orderers/orderer2.election_commission/tls/keystore/* ${PWD}/ca/organizations/election_commission/orderers/orderer2.election_commission/tls/server.key

  mkdir -p ${PWD}/ca/organizations/election_commission/orderers/orderer2.election_commission/msp/tlscacerts
  cp ${PWD}/ca/organizations/election_commission/orderers/orderer2.election_commission/tls/tlscacerts/* ${PWD}/ca/organizations/election_commission/orderers/orderer2.election_commission/msp/tlscacerts/tlsca.election_commission-cert.pem

  # mkdir -p ${PWD}/ca/organizations/election_commission/msp/tlscacerts
  # cp ${PWD}/ca/organizations/election_commission/orderers/orderer2.election_commission/tls/tlscacerts/* ${PWD}/ca/organizations/election_commission/msp/tlscacerts/tlsca.election_commission-cert.pem







  infoln "Registering orderer"
  set -x
  fabric-ca-client register --caname election_commission_ca --id.name orderer3 --id.secret ordererpw --id.type orderer --tls.certfiles ${PWD}/ca/server/election_commission/tls-cert.pem
  { set +x; } 2>/dev/null




  infoln "Generating the orderer msp"
  set -x
  fabric-ca-client enroll -u https://orderer3:ordererpw@localhost:9054 --caname election_commission_ca -M ${PWD}/ca/organizations/election_commission/orderers/orderer3.election_commission/msp --csr.hosts orderer3.election_commission --csr.hosts localhost --tls.certfiles ${PWD}/ca/server/election_commission/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/ca/organizations/election_commission/msp/config.yaml ${PWD}/ca/organizations/election_commission/orderers/orderer3.election_commission/msp/config.yaml

  infoln "Generating the orderer-tls certificates"
  set -x
  fabric-ca-client enroll -u https://orderer3:ordererpw@localhost:9054 --caname election_commission_ca -M ${PWD}/ca/organizations/election_commission/orderers/orderer3.election_commission/tls --enrollment.profile tls --csr.hosts orderer3.election_commission --csr.hosts localhost --tls.certfiles ${PWD}/ca/server/election_commission/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/ca/organizations/election_commission/orderers/orderer3.election_commission/tls/tlscacerts/* ${PWD}/ca/organizations/election_commission/orderers/orderer3.election_commission/tls/ca.crt
  cp ${PWD}/ca/organizations/election_commission/orderers/orderer3.election_commission/tls/signcerts/* ${PWD}/ca/organizations/election_commission/orderers/orderer3.election_commission/tls/server.crt
  cp ${PWD}/ca/organizations/election_commission/orderers/orderer3.election_commission/tls/keystore/* ${PWD}/ca/organizations/election_commission/orderers/orderer3.election_commission/tls/server.key

  mkdir -p ${PWD}/ca/organizations/election_commission/orderers/orderer3.election_commission/msp/tlscacerts
  cp ${PWD}/ca/organizations/election_commission/orderers/orderer3.election_commission/tls/tlscacerts/* ${PWD}/ca/organizations/election_commission/orderers/orderer3.election_commission/msp/tlscacerts/tlsca.election_commission-cert.pem

  # mkdir -p ${PWD}/ca/organizations/election_commission/msp/tlscacerts
  # cp ${PWD}/ca/organizations/election_commission/orderers/orderer3.election_commission/tls/tlscacerts/* ${PWD}/ca/organizations/election_commission/msp/tlscacerts/tlsca.election_commission-cert.pem









  infoln "Registering peer0"
  set -x
  fabric-ca-client register --caname election_commission_ca --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles ${PWD}/ca/server/election_commission/tls-cert.pem
  { set +x; } 2>/dev/null



  infoln "Generating the peer0 msp"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:9054 --caname election_commission_ca -M ${PWD}/ca/organizations/election_commission/peers/peer0.election_commission/msp --csr.hosts peer0.election_commission  --tls.certfiles ${PWD}/ca/server/election_commission/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/ca/organizations/election_commission/msp/config.yaml ${PWD}/ca/organizations/election_commission/peers/peer0.election_commission/msp/config.yaml

  infoln "Generating the peer0-tls certificates"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:9054 --caname election_commission_ca -M ${PWD}/ca/organizations/election_commission/peers/peer0.election_commission/tls --enrollment.profile tls --csr.hosts peer0.election_commission --csr.hosts localhost  --tls.certfiles ${PWD}/ca/server/election_commission/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/ca/organizations/election_commission/peers/peer0.election_commission/tls/tlscacerts/* ${PWD}/ca/organizations/election_commission/peers/peer0.election_commission/tls/ca.crt
  cp ${PWD}/ca/organizations/election_commission/peers/peer0.election_commission/tls/signcerts/* ${PWD}/ca/organizations/election_commission/peers/peer0.election_commission/tls/server.crt
  cp ${PWD}/ca/organizations/election_commission/peers/peer0.election_commission/tls/keystore/* ${PWD}/ca/organizations/election_commission/peers/peer0.election_commission/tls/server.key

  mkdir -p ${PWD}/ca/organizations/election_commission/msp/tlscacerts
  cp ${PWD}/ca/organizations/election_commission/peers/peer0.election_commission/tls/tlscacerts/* ${PWD}/ca/organizations/election_commission/msp/tlscacerts/ca.crt

  # mkdir -p ${PWD}/ca/organizations/election_commission/tlsca
  # cp ${PWD}/ca/organizations/election_commission/peers/peer0.election_commission/tls/tlscacerts/* ${PWD}/ca/organizations/election_commission/tlsca/tlsca.election_commission-cert.pem

  mkdir -p ${PWD}/ca/organizations/election_commission/ca
  cp ${PWD}/ca/organizations/election_commission/peers/peer0.election_commission/msp/cacerts/* ${PWD}/ca/organizations/election_commission/ca/election_commission-cert.pem







  infoln "Generating the admin msp"
  set -x
  fabric-ca-client enroll -u https://ordererAdmin:ordererAdminpw@localhost:9054 --caname election_commission_ca -M ${PWD}/ca/organizations/election_commission/users/Admin@election_commission/msp --tls.certfiles ${PWD}/ca/server/election_commission/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/ca/organizations/election_commission/msp/config.yaml ${PWD}/ca/organizations/election_commission/users/Admin@election_commission/msp/config.yaml
}

function createMyParty() {
  infoln "Enrolling the CA admin"
  mkdir -p ca/organizations/my_party

  export FABRIC_CA_CLIENT_HOME=${PWD}/ca/organizations/my_party/

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:7054 --caname my_party_ca --tls.certfiles ${PWD}/ca/server/my_party/tls-cert.pem
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-7054-my_party_ca.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-7054-my_party_ca.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-7054-my_party_ca.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-7054-my_party_ca.pem
    OrganizationalUnitIdentifier: orderer' >${PWD}/ca/organizations/my_party/msp/config.yaml

  infoln "Registering peer0"
  set -x
  fabric-ca-client register --caname my_party_ca --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles ${PWD}/ca/server/my_party/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Registering user"
  set -x
  fabric-ca-client register --caname my_party_ca --id.name user1 --id.secret user1pw --id.type client --tls.certfiles ${PWD}/ca/server/my_party/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Registering the org admin"
  set -x
  fabric-ca-client register --caname my_party_ca --id.name org1admin --id.secret org1adminpw --id.type admin --tls.certfiles ${PWD}/ca/server/my_party/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Generating the peer0 msp"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7054 --caname my_party_ca -M ${PWD}/ca/organizations/my_party/peers/peer0.my_party/msp --csr.hosts peer0.my_party --tls.certfiles ${PWD}/ca/server/my_party/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/ca/organizations/my_party/msp/config.yaml ${PWD}/ca/organizations/my_party/peers/peer0.my_party/msp/config.yaml

  infoln "Generating the peer0-tls certificates"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7054 --caname my_party_ca -M ${PWD}/ca/organizations/my_party/peers/peer0.my_party/tls --enrollment.profile tls --csr.hosts peer0.my_party --csr.hosts localhost --tls.certfiles ${PWD}/ca/server/my_party/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/ca/organizations/my_party/peers/peer0.my_party/tls/tlscacerts/* ${PWD}/ca/organizations/my_party/peers/peer0.my_party/tls/ca.crt
  cp ${PWD}/ca/organizations/my_party/peers/peer0.my_party/tls/signcerts/* ${PWD}/ca/organizations/my_party/peers/peer0.my_party/tls/server.crt
  cp ${PWD}/ca/organizations/my_party/peers/peer0.my_party/tls/keystore/* ${PWD}/ca/organizations/my_party/peers/peer0.my_party/tls/server.key

  mkdir -p ${PWD}/ca/organizations/my_party/msp/tlscacerts
  cp ${PWD}/ca/organizations/my_party/peers/peer0.my_party/tls/tlscacerts/* ${PWD}/ca/organizations/my_party/msp/tlscacerts/ca.crt

  mkdir -p ${PWD}/ca/organizations/my_party/tlsca
  cp ${PWD}/ca/organizations/my_party/peers/peer0.my_party/tls/tlscacerts/* ${PWD}/ca/organizations/my_party/tlsca/tlsca.my_party-cert.pem

  mkdir -p ${PWD}/ca/organizations/my_party/ca
  cp ${PWD}/ca/organizations/my_party/peers/peer0.my_party/msp/cacerts/* ${PWD}/ca/organizations/my_party/ca/ca.my_party-cert.pem

  infoln "Generating the user msp"
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@localhost:7054 --caname my_party_ca -M ${PWD}/ca/organizations/my_party/users/User1@my_party/msp --tls.certfiles ${PWD}/ca/server/my_party/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/ca/organizations/my_party/msp/config.yaml ${PWD}/ca/organizations/my_party/users/User1@my_party/msp/config.yaml

  infoln "Generating the org admin msp"
  set -x
  fabric-ca-client enroll -u https://org1admin:org1adminpw@localhost:7054 --caname my_party_ca -M ${PWD}/ca/organizations/my_party/users/Admin@my_party/msp --tls.certfiles ${PWD}/ca/server/my_party/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/ca/organizations/my_party/msp/config.yaml ${PWD}/ca/organizations/my_party/users/Admin@my_party/msp/config.yaml
}

createElectionCommission

createMyParty