#!/bin/bash

source scriptUtils.sh
export PATH=${PWD}/../bin:$PATH
function createUaOrg() {
  mkdir channel-artifacts
  infoln "Enroll the CA admin"
  sleep 2
  mkdir -p organizations/peerOrganizations/ua.bcfm.com/

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/ua.bcfm.com/
  #  rm -rf $FABRIC_CA_CLIENT_HOME/fabric-ca-client-config.yaml
  #  rm -rf $FABRIC_CA_CLIENT_HOME/msp

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:7054 --caname ca-ua --tls.certfiles ${PWD}/organizations/fabric-ca/ua/tls-cert.pem
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-ua.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-ua.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-ua.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-ua.pem
    OrganizationalUnitIdentifier: orderer' >${PWD}/organizations/peerOrganizations/ua.bcfm.com/msp/config.yaml

  # This section is for giving permission to users
  infoln "Register peer0 of UA Org"
  set -x
  fabric-ca-client register --caname ca-ua --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles ${PWD}/organizations/fabric-ca/ua/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Register user"
  set -x
  fabric-ca-client register --caname ca-ua --id.name user1 --id.secret user1pw --id.type client --tls.certfiles ${PWD}/organizations/fabric-ca/ua/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Register the org admin"
  set -x
  fabric-ca-client register --caname ca-ua --id.name uaadmin --id.secret uaadminpw --id.type admin --tls.certfiles ${PWD}/organizations/fabric-ca/ua/tls-cert.pem
  { set +x; } 2>/dev/null

  mkdir -p organizations/peerOrganizations/ua.bcfm.com/peers
  mkdir -p organizations/peerOrganizations/ua.bcfm.com/peers/peer0.ua.bcfm.com

  infoln "Generate the peer0 msp"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7054 --caname ca-ua -M ${PWD}/organizations/peerOrganizations/ua.bcfm.com/peers/peer0.ua.bcfm.com/msp --csr.hosts peer0.ua.bcfm.com --tls.certfiles ${PWD}/organizations/fabric-ca/ua/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/ua.bcfm.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/ua.bcfm.com/peers/peer0.ua.bcfm.com/msp/config.yaml

  infoln "Generate the peer0-tls certificates"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7054 --caname ca-ua -M ${PWD}/organizations/peerOrganizations/ua.bcfm.com/peers/peer0.ua.bcfm.com/tls --enrollment.profile tls --csr.hosts peer0.ua.bcfm.com --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/ua/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/ua.bcfm.com/peers/peer0.ua.bcfm.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/ua.bcfm.com/peers/peer0.ua.bcfm.com/tls/ca.crt
  cp ${PWD}/organizations/peerOrganizations/ua.bcfm.com/peers/peer0.ua.bcfm.com/tls/signcerts/* ${PWD}/organizations/peerOrganizations/ua.bcfm.com/peers/peer0.ua.bcfm.com/tls/server.crt
  cp ${PWD}/organizations/peerOrganizations/ua.bcfm.com/peers/peer0.ua.bcfm.com/tls/keystore/* ${PWD}/organizations/peerOrganizations/ua.bcfm.com/peers/peer0.ua.bcfm.com/tls/server.key

  mkdir -p ${PWD}/organizations/peerOrganizations/ua.bcfm.com/msp/tlscacerts
  cp ${PWD}/organizations/peerOrganizations/ua.bcfm.com/peers/peer0.ua.bcfm.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/ua.bcfm.com/msp/tlscacerts/ca.crt

  mkdir -p ${PWD}/organizations/peerOrganizations/ua.bcfm.com/tlsca
  cp ${PWD}/organizations/peerOrganizations/ua.bcfm.com/peers/peer0.ua.bcfm.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/ua.bcfm.com/tlsca/tlsca.ua.bcfm.com-cert.pem

  mkdir -p ${PWD}/organizations/peerOrganizations/ua.bcfm.com/ca
  cp ${PWD}/organizations/peerOrganizations/ua.bcfm.com/peers/peer0.ua.bcfm.com/msp/cacerts/* ${PWD}/organizations/peerOrganizations/ua.bcfm.com/ca/ca.ua.bcfm.com-cert.pem

  mkdir -p organizations/peerOrganizations/ua.bcfm.com/users
  mkdir -p organizations/peerOrganizations/ua.bcfm.com/users/User1@ua.bcfm.com

  infoln "Generate the user msp"
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@localhost:7054 --caname ca-ua -M ${PWD}/organizations/peerOrganizations/ua.bcfm.com/users/User1@ua.bcfm.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/ua/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/ua.bcfm.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/ua.bcfm.com/users/User1@ua.bcfm.com/msp/config.yaml

  mkdir -p organizations/peerOrganizations/ua.bcfm.com/users/Admin@ua.bcfm.com

  infoln "Generate the org admin msp"
  set -x
  fabric-ca-client enroll -u https://uaadmin:uaadminpw@localhost:7054 --caname ca-ua -M ${PWD}/organizations/peerOrganizations/ua.bcfm.com/users/Admin@ua.bcfm.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/ua/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/ua.bcfm.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/ua.bcfm.com/users/Admin@ua.bcfm.com/msp/config.yaml

}

function createAgencyOrg() {
  mkdir channel-artifacts
  infoln "Enroll the CA admin"
  sleep 2
  mkdir -p organizations/peerOrganizations/agency.bcfm.com/

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/agency.bcfm.com/
  #  rm -rf $FABRIC_CA_CLIENT_HOME/fabric-ca-client-config.yaml
  #  rm -rf $FABRIC_CA_CLIENT_HOME/msp

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:12054 --caname ca-agency --tls.certfiles ${PWD}/organizations/fabric-ca/agency/tls-cert.pem
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-12054-ca-agency.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-12054-ca-agency.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-12054-ca-agency.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-12054-ca-agency.pem
    OrganizationalUnitIdentifier: orderer' >${PWD}/organizations/peerOrganizations/agency.bcfm.com/msp/config.yaml

  # This section is for giving permission to users
  infoln "Register peer0 of agency Org"
  set -x
  fabric-ca-client register --caname ca-agency --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles ${PWD}/organizations/fabric-ca/agency/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Register user"
  set -x
  fabric-ca-client register --caname ca-agency --id.name user1 --id.secret user1pw --id.type client --tls.certfiles ${PWD}/organizations/fabric-ca/agency/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Register the org admin"
  set -x
  fabric-ca-client register --caname ca-agency --id.name agencyadmin --id.secret agencyadminpw --id.type admin --tls.certfiles ${PWD}/organizations/fabric-ca/agency/tls-cert.pem
  { set +x; } 2>/dev/null

  mkdir -p organizations/peerOrganizations/agency.bcfm.com/peers
  mkdir -p organizations/peerOrganizations/agency.bcfm.com/peers/peer0.agency.bcfm.com

  infoln "Generate the peer0 msp"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:12054 --caname ca-agency -M ${PWD}/organizations/peerOrganizations/agency.bcfm.com/peers/peer0.agency.bcfm.com/msp --csr.hosts peer0.agency.bcfm.com --tls.certfiles ${PWD}/organizations/fabric-ca/agency/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/agency.bcfm.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/agency.bcfm.com/peers/peer0.agency.bcfm.com/msp/config.yaml

  infoln "Generate the peer0-tls certificates"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:12054 --caname ca-agency -M ${PWD}/organizations/peerOrganizations/agency.bcfm.com/peers/peer0.agency.bcfm.com/tls --enrollment.profile tls --csr.hosts peer0.agency.bcfm.com --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/agency/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/agency.bcfm.com/peers/peer0.agency.bcfm.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/agency.bcfm.com/peers/peer0.agency.bcfm.com/tls/ca.crt
  cp ${PWD}/organizations/peerOrganizations/agency.bcfm.com/peers/peer0.agency.bcfm.com/tls/signcerts/* ${PWD}/organizations/peerOrganizations/agency.bcfm.com/peers/peer0.agency.bcfm.com/tls/server.crt
  cp ${PWD}/organizations/peerOrganizations/agency.bcfm.com/peers/peer0.agency.bcfm.com/tls/keystore/* ${PWD}/organizations/peerOrganizations/agency.bcfm.com/peers/peer0.agency.bcfm.com/tls/server.key

  mkdir -p ${PWD}/organizations/peerOrganizations/agency.bcfm.com/msp/tlscacerts
  cp ${PWD}/organizations/peerOrganizations/agency.bcfm.com/peers/peer0.agency.bcfm.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/agency.bcfm.com/msp/tlscacerts/ca.crt

  mkdir -p ${PWD}/organizations/peerOrganizations/agency.bcfm.com/tlsca
  cp ${PWD}/organizations/peerOrganizations/agency.bcfm.com/peers/peer0.agency.bcfm.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/agency.bcfm.com/tlsca/tlsca.agency.bcfm.com-cert.pem

  mkdir -p ${PWD}/organizations/peerOrganizations/agency.bcfm.com/ca
  cp ${PWD}/organizations/peerOrganizations/agency.bcfm.com/peers/peer0.agency.bcfm.com/msp/cacerts/* ${PWD}/organizations/peerOrganizations/agency.bcfm.com/ca/ca.agency.bcfm.com-cert.pem

  mkdir -p organizations/peerOrganizations/agency.bcfm.com/users
  mkdir -p organizations/peerOrganizations/agency.bcfm.com/users/User1@agency.bcfm.com

  infoln "Generate the user msp"
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@localhost:12054 --caname ca-agency -M ${PWD}/organizations/peerOrganizations/agency.bcfm.com/users/User1@agency.bcfm.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/agency/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/agency.bcfm.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/agency.bcfm.com/users/User1@agency.bcfm.com/msp/config.yaml

  mkdir -p organizations/peerOrganizations/agency.bcfm.com/users/Admin@agency.bcfm.com

  infoln "Generate the org admin msp"
  set -x
  fabric-ca-client enroll -u https://agencyadmin:agencyadminpw@localhost:12054 --caname ca-agency -M ${PWD}/organizations/peerOrganizations/agency.bcfm.com/users/Admin@agency.bcfm.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/agency/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/agency.bcfm.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/agency.bcfm.com/users/Admin@agency.bcfm.com/msp/config.yaml

}

function createFarmacyOrg() {
  mkdir channel-artifacts
  infoln "Enroll the CA admin"
  sleep 2
  mkdir -p organizations/peerOrganizations/farmacy.bcfm.com/

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/farmacy.bcfm.com/
  #  rm -rf $FABRIC_CA_CLIENT_HOME/fabric-ca-client-config.yaml
  #  rm -rf $FABRIC_CA_CLIENT_HOME/msp

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:11054 --caname ca-farmacy --tls.certfiles ${PWD}/organizations/fabric-ca/farmacy/tls-cert.pem
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-11054-ca-farmacy.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-11054-ca-farmacy.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-11054-ca-farmacy.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-11054-ca-farmacy.pem
    OrganizationalUnitIdentifier: orderer' >${PWD}/organizations/peerOrganizations/farmacy.bcfm.com/msp/config.yaml

  # This section is for giving permission to users
  infoln "Register peer0 of farmacy Org"
  set -x
  fabric-ca-client register --caname ca-farmacy --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles ${PWD}/organizations/fabric-ca/farmacy/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Register user"
  set -x
  fabric-ca-client register --caname ca-farmacy --id.name user1 --id.secret user1pw --id.type client --tls.certfiles ${PWD}/organizations/fabric-ca/farmacy/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Register the org admin"
  set -x
  fabric-ca-client register --caname ca-farmacy --id.name farmacyadmin --id.secret farmacyadminpw --id.type admin --tls.certfiles ${PWD}/organizations/fabric-ca/farmacy/tls-cert.pem
  { set +x; } 2>/dev/null

  mkdir -p organizations/peerOrganizations/farmacy.bcfm.com/peers
  mkdir -p organizations/peerOrganizations/farmacy.bcfm.com/peers/peer0.farmacy.bcfm.com

  infoln "Generate the peer0 msp"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:11054 --caname ca-farmacy -M ${PWD}/organizations/peerOrganizations/farmacy.bcfm.com/peers/peer0.farmacy.bcfm.com/msp --csr.hosts peer0.farmacy.bcfm.com --tls.certfiles ${PWD}/organizations/fabric-ca/farmacy/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/farmacy.bcfm.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/farmacy.bcfm.com/peers/peer0.farmacy.bcfm.com/msp/config.yaml

  infoln "Generate the peer0-tls certificates"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:11054 --caname ca-farmacy -M ${PWD}/organizations/peerOrganizations/farmacy.bcfm.com/peers/peer0.farmacy.bcfm.com/tls --enrollment.profile tls --csr.hosts peer0.farmacy.bcfm.com --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/farmacy/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/farmacy.bcfm.com/peers/peer0.farmacy.bcfm.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/farmacy.bcfm.com/peers/peer0.farmacy.bcfm.com/tls/ca.crt
  cp ${PWD}/organizations/peerOrganizations/farmacy.bcfm.com/peers/peer0.farmacy.bcfm.com/tls/signcerts/* ${PWD}/organizations/peerOrganizations/farmacy.bcfm.com/peers/peer0.farmacy.bcfm.com/tls/server.crt
  cp ${PWD}/organizations/peerOrganizations/farmacy.bcfm.com/peers/peer0.farmacy.bcfm.com/tls/keystore/* ${PWD}/organizations/peerOrganizations/farmacy.bcfm.com/peers/peer0.farmacy.bcfm.com/tls/server.key

  mkdir -p ${PWD}/organizations/peerOrganizations/farmacy.bcfm.com/msp/tlscacerts
  cp ${PWD}/organizations/peerOrganizations/farmacy.bcfm.com/peers/peer0.farmacy.bcfm.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/farmacy.bcfm.com/msp/tlscacerts/ca.crt

  mkdir -p ${PWD}/organizations/peerOrganizations/farmacy.bcfm.com/tlsca
  cp ${PWD}/organizations/peerOrganizations/farmacy.bcfm.com/peers/peer0.farmacy.bcfm.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/farmacy.bcfm.com/tlsca/tlsca.farmacy.bcfm.com-cert.pem

  mkdir -p ${PWD}/organizations/peerOrganizations/farmacy.bcfm.com/ca
  cp ${PWD}/organizations/peerOrganizations/farmacy.bcfm.com/peers/peer0.farmacy.bcfm.com/msp/cacerts/* ${PWD}/organizations/peerOrganizations/farmacy.bcfm.com/ca/ca.farmacy.bcfm.com-cert.pem

  mkdir -p organizations/peerOrganizations/farmacy.bcfm.com/users
  mkdir -p organizations/peerOrganizations/farmacy.bcfm.com/users/User1@farmacy.bcfm.com

  infoln "Generate the user msp"
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@localhost:11054 --caname ca-farmacy -M ${PWD}/organizations/peerOrganizations/farmacy.bcfm.com/users/User1@farmacy.bcfm.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/farmacy/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/farmacy.bcfm.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/farmacy.bcfm.com/users/User1@farmacy.bcfm.com/msp/config.yaml

  mkdir -p organizations/peerOrganizations/farmacy.bcfm.com/users/Admin@farmacy.bcfm.com

  infoln "Generate the org admin msp"
  set -x
  fabric-ca-client enroll -u https://farmacyadmin:farmacyadminpw@localhost:11054 --caname ca-farmacy -M ${PWD}/organizations/peerOrganizations/farmacy.bcfm.com/users/Admin@farmacy.bcfm.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/farmacy/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/farmacy.bcfm.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/farmacy.bcfm.com/users/Admin@farmacy.bcfm.com/msp/config.yaml

}

function createProducerOrg() {
  mkdir channel-artifacts
  infoln "Enroll the CA admin"
  sleep 2
  mkdir -p organizations/peerOrganizations/producer.bcfm.com/

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/producer.bcfm.com/
  #  rm -rf $FABRIC_CA_CLIENT_HOME/fabric-ca-client-config.yaml
  #  rm -rf $FABRIC_CA_CLIENT_HOME/msp

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:10054 --caname ca-producer --tls.certfiles ${PWD}/organizations/fabric-ca/producer/tls-cert.pem
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-10054-ca-producer.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-10054-ca-producer.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-10054-ca-producer.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-10054-ca-producer.pem
    OrganizationalUnitIdentifier: orderer' >${PWD}/organizations/peerOrganizations/producer.bcfm.com/msp/config.yaml

  # This section is for giving permission to users
  infoln "Register peer0 of producer Org"
  set -x
  fabric-ca-client register --caname ca-producer --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles ${PWD}/organizations/fabric-ca/producer/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Register user"
  set -x
  fabric-ca-client register --caname ca-producer --id.name user1 --id.secret user1pw --id.type client --tls.certfiles ${PWD}/organizations/fabric-ca/producer/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Register the org admin"
  set -x
  fabric-ca-client register --caname ca-producer --id.name produceradmin --id.secret produceradminpw --id.type admin --tls.certfiles ${PWD}/organizations/fabric-ca/producer/tls-cert.pem
  { set +x; } 2>/dev/null

  mkdir -p organizations/peerOrganizations/producer.bcfm.com/peers
  mkdir -p organizations/peerOrganizations/producer.bcfm.com/peers/peer0.producer.bcfm.com

  infoln "Generate the peer0 msp"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:10054 --caname ca-producer -M ${PWD}/organizations/peerOrganizations/producer.bcfm.com/peers/peer0.producer.bcfm.com/msp --csr.hosts peer0.producer.bcfm.com --tls.certfiles ${PWD}/organizations/fabric-ca/producer/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/producer.bcfm.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/producer.bcfm.com/peers/peer0.producer.bcfm.com/msp/config.yaml

  infoln "Generate the peer0-tls certificates"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:10054 --caname ca-producer -M ${PWD}/organizations/peerOrganizations/producer.bcfm.com/peers/peer0.producer.bcfm.com/tls --enrollment.profile tls --csr.hosts peer0.producer.bcfm.com --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/producer/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/producer.bcfm.com/peers/peer0.producer.bcfm.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/producer.bcfm.com/peers/peer0.producer.bcfm.com/tls/ca.crt
  cp ${PWD}/organizations/peerOrganizations/producer.bcfm.com/peers/peer0.producer.bcfm.com/tls/signcerts/* ${PWD}/organizations/peerOrganizations/producer.bcfm.com/peers/peer0.producer.bcfm.com/tls/server.crt
  cp ${PWD}/organizations/peerOrganizations/producer.bcfm.com/peers/peer0.producer.bcfm.com/tls/keystore/* ${PWD}/organizations/peerOrganizations/producer.bcfm.com/peers/peer0.producer.bcfm.com/tls/server.key

  mkdir -p ${PWD}/organizations/peerOrganizations/producer.bcfm.com/msp/tlscacerts
  cp ${PWD}/organizations/peerOrganizations/producer.bcfm.com/peers/peer0.producer.bcfm.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/producer.bcfm.com/msp/tlscacerts/ca.crt

  mkdir -p ${PWD}/organizations/peerOrganizations/producer.bcfm.com/tlsca
  cp ${PWD}/organizations/peerOrganizations/producer.bcfm.com/peers/peer0.producer.bcfm.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/producer.bcfm.com/tlsca/tlsca.producer.bcfm.com-cert.pem

  mkdir -p ${PWD}/organizations/peerOrganizations/producer.bcfm.com/ca
  cp ${PWD}/organizations/peerOrganizations/producer.bcfm.com/peers/peer0.producer.bcfm.com/msp/cacerts/* ${PWD}/organizations/peerOrganizations/producer.bcfm.com/ca/ca.producer.bcfm.com-cert.pem

  mkdir -p organizations/peerOrganizations/producer.bcfm.com/users
  mkdir -p organizations/peerOrganizations/producer.bcfm.com/users/User1@producer.bcfm.com

  infoln "Generate the user msp"
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@localhost:10054 --caname ca-producer -M ${PWD}/organizations/peerOrganizations/producer.bcfm.com/users/User1@producer.bcfm.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/producer/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/producer.bcfm.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/producer.bcfm.com/users/User1@producer.bcfm.com/msp/config.yaml

  mkdir -p organizations/peerOrganizations/producer.bcfm.com/users/Admin@producer.bcfm.com

  infoln "Generate the org admin msp"
  set -x
  fabric-ca-client enroll -u https://produceradmin:produceradminpw@localhost:10054 --caname ca-producer -M ${PWD}/organizations/peerOrganizations/producer.bcfm.com/users/Admin@producer.bcfm.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/producer/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/producer.bcfm.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/producer.bcfm.com/users/Admin@producer.bcfm.com/msp/config.yaml

}

function createProviderOrg() {
  mkdir channel-artifacts
  infoln "Enroll the CA admin"
  sleep 2
  mkdir -p organizations/peerOrganizations/provider.bcfm.com/

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/provider.bcfm.com/
  #  rm -rf $FABRIC_CA_CLIENT_HOME/fabric-ca-client-config.yaml
  #  rm -rf $FABRIC_CA_CLIENT_HOME/msp

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:9054 --caname ca-provider --tls.certfiles ${PWD}/organizations/fabric-ca/provider/tls-cert.pem
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-provider.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-provider.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-provider.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-provider.pem
    OrganizationalUnitIdentifier: orderer' >${PWD}/organizations/peerOrganizations/provider.bcfm.com/msp/config.yaml

  # This section is for giving permission to users
  infoln "Register peer0 of provider Org"
  set -x
  fabric-ca-client register --caname ca-provider --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles ${PWD}/organizations/fabric-ca/provider/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Register user"
  set -x
  fabric-ca-client register --caname ca-provider --id.name user1 --id.secret user1pw --id.type client --tls.certfiles ${PWD}/organizations/fabric-ca/provider/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Register the org admin"
  set -x
  fabric-ca-client register --caname ca-provider --id.name provideradmin --id.secret provideradminpw --id.type admin --tls.certfiles ${PWD}/organizations/fabric-ca/provider/tls-cert.pem
  { set +x; } 2>/dev/null

  mkdir -p organizations/peerOrganizations/provider.bcfm.com/peers
  mkdir -p organizations/peerOrganizations/provider.bcfm.com/peers/peer0.provider.bcfm.com

  infoln "Generate the peer0 msp"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:9054 --caname ca-provider -M ${PWD}/organizations/peerOrganizations/provider.bcfm.com/peers/peer0.provider.bcfm.com/msp --csr.hosts peer0.provider.bcfm.com --tls.certfiles ${PWD}/organizations/fabric-ca/provider/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/provider.bcfm.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/provider.bcfm.com/peers/peer0.provider.bcfm.com/msp/config.yaml

  infoln "Generate the peer0-tls certificates"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:9054 --caname ca-provider -M ${PWD}/organizations/peerOrganizations/provider.bcfm.com/peers/peer0.provider.bcfm.com/tls --enrollment.profile tls --csr.hosts peer0.provider.bcfm.com --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/provider/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/provider.bcfm.com/peers/peer0.provider.bcfm.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/provider.bcfm.com/peers/peer0.provider.bcfm.com/tls/ca.crt
  cp ${PWD}/organizations/peerOrganizations/provider.bcfm.com/peers/peer0.provider.bcfm.com/tls/signcerts/* ${PWD}/organizations/peerOrganizations/provider.bcfm.com/peers/peer0.provider.bcfm.com/tls/server.crt
  cp ${PWD}/organizations/peerOrganizations/provider.bcfm.com/peers/peer0.provider.bcfm.com/tls/keystore/* ${PWD}/organizations/peerOrganizations/provider.bcfm.com/peers/peer0.provider.bcfm.com/tls/server.key

  mkdir -p ${PWD}/organizations/peerOrganizations/provider.bcfm.com/msp/tlscacerts
  cp ${PWD}/organizations/peerOrganizations/provider.bcfm.com/peers/peer0.provider.bcfm.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/provider.bcfm.com/msp/tlscacerts/ca.crt

  mkdir -p ${PWD}/organizations/peerOrganizations/provider.bcfm.com/tlsca
  cp ${PWD}/organizations/peerOrganizations/provider.bcfm.com/peers/peer0.provider.bcfm.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/provider.bcfm.com/tlsca/tlsca.provider.bcfm.com-cert.pem

  mkdir -p ${PWD}/organizations/peerOrganizations/provider.bcfm.com/ca
  cp ${PWD}/organizations/peerOrganizations/provider.bcfm.com/peers/peer0.provider.bcfm.com/msp/cacerts/* ${PWD}/organizations/peerOrganizations/provider.bcfm.com/ca/ca.provider.bcfm.com-cert.pem

  mkdir -p organizations/peerOrganizations/provider.bcfm.com/users
  mkdir -p organizations/peerOrganizations/provider.bcfm.com/users/User1@provider.bcfm.com

  infoln "Generate the user msp"
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@localhost:9054 --caname ca-provider -M ${PWD}/organizations/peerOrganizations/provider.bcfm.com/users/User1@provider.bcfm.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/provider/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/provider.bcfm.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/provider.bcfm.com/users/User1@provider.bcfm.com/msp/config.yaml

  mkdir -p organizations/peerOrganizations/provider.bcfm.com/users/Admin@provider.bcfm.com

  infoln "Generate the org admin msp"
  set -x
  fabric-ca-client enroll -u https://provideradmin:provideradminpw@localhost:9054 --caname ca-provider -M ${PWD}/organizations/peerOrganizations/provider.bcfm.com/users/Admin@provider.bcfm.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/provider/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/provider.bcfm.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/provider.bcfm.com/users/Admin@provider.bcfm.com/msp/config.yaml

}

function createTransportOrg() {
  mkdir channel-artifacts
  infoln "Enroll the CA admin"
  sleep 2
  mkdir -p organizations/peerOrganizations/transport.bcfm.com/

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/transport.bcfm.com/
  #  rm -rf $FABRIC_CA_CLIENT_HOME/fabric-ca-client-config.yaml
  #  rm -rf $FABRIC_CA_CLIENT_HOME/msp

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:8054 --caname ca-transport --tls.certfiles ${PWD}/organizations/fabric-ca/transport/tls-cert.pem
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-transport.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-transport.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-transport.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-transport.pem
    OrganizationalUnitIdentifier: orderer' >${PWD}/organizations/peerOrganizations/transport.bcfm.com/msp/config.yaml

  # This section is for giving permission to users
  infoln "Register peer0 of transport Org"
  set -x
  fabric-ca-client register --caname ca-transport --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles ${PWD}/organizations/fabric-ca/transport/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Register user"
  set -x
  fabric-ca-client register --caname ca-transport --id.name user1 --id.secret user1pw --id.type client --tls.certfiles ${PWD}/organizations/fabric-ca/transport/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Register the org admin"
  set -x
  fabric-ca-client register --caname ca-transport --id.name transportadmin --id.secret transportadminpw --id.type admin --tls.certfiles ${PWD}/organizations/fabric-ca/transport/tls-cert.pem
  { set +x; } 2>/dev/null

  mkdir -p organizations/peerOrganizations/transport.bcfm.com/peers
  mkdir -p organizations/peerOrganizations/transport.bcfm.com/peers/peer0.transport.bcfm.com

  infoln "Generate the peer0 msp"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:8054 --caname ca-transport -M ${PWD}/organizations/peerOrganizations/transport.bcfm.com/peers/peer0.transport.bcfm.com/msp --csr.hosts peer0.transport.bcfm.com --tls.certfiles ${PWD}/organizations/fabric-ca/transport/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/transport.bcfm.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/transport.bcfm.com/peers/peer0.transport.bcfm.com/msp/config.yaml

  infoln "Generate the peer0-tls certificates"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:8054 --caname ca-transport -M ${PWD}/organizations/peerOrganizations/transport.bcfm.com/peers/peer0.transport.bcfm.com/tls --enrollment.profile tls --csr.hosts peer0.transport.bcfm.com --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/transport/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/transport.bcfm.com/peers/peer0.transport.bcfm.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/transport.bcfm.com/peers/peer0.transport.bcfm.com/tls/ca.crt
  cp ${PWD}/organizations/peerOrganizations/transport.bcfm.com/peers/peer0.transport.bcfm.com/tls/signcerts/* ${PWD}/organizations/peerOrganizations/transport.bcfm.com/peers/peer0.transport.bcfm.com/tls/server.crt
  cp ${PWD}/organizations/peerOrganizations/transport.bcfm.com/peers/peer0.transport.bcfm.com/tls/keystore/* ${PWD}/organizations/peerOrganizations/transport.bcfm.com/peers/peer0.transport.bcfm.com/tls/server.key

  mkdir -p ${PWD}/organizations/peerOrganizations/transport.bcfm.com/msp/tlscacerts
  cp ${PWD}/organizations/peerOrganizations/transport.bcfm.com/peers/peer0.transport.bcfm.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/transport.bcfm.com/msp/tlscacerts/ca.crt

  mkdir -p ${PWD}/organizations/peerOrganizations/transport.bcfm.com/tlsca
  cp ${PWD}/organizations/peerOrganizations/transport.bcfm.com/peers/peer0.transport.bcfm.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/transport.bcfm.com/tlsca/tlsca.transport.bcfm.com-cert.pem

  mkdir -p ${PWD}/organizations/peerOrganizations/transport.bcfm.com/ca
  cp ${PWD}/organizations/peerOrganizations/transport.bcfm.com/peers/peer0.transport.bcfm.com/msp/cacerts/* ${PWD}/organizations/peerOrganizations/transport.bcfm.com/ca/ca.transport.bcfm.com-cert.pem

  mkdir -p organizations/peerOrganizations/transport.bcfm.com/users
  mkdir -p organizations/peerOrganizations/transport.bcfm.com/users/User1@transport.bcfm.com

  infoln "Generate the user msp"
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@localhost:8054 --caname ca-transport -M ${PWD}/organizations/peerOrganizations/transport.bcfm.com/users/User1@transport.bcfm.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/transport/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/transport.bcfm.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/transport.bcfm.com/users/User1@transport.bcfm.com/msp/config.yaml

  mkdir -p organizations/peerOrganizations/transport.bcfm.com/users/Admin@transport.bcfm.com

  infoln "Generate the org admin msp"
  set -x
  fabric-ca-client enroll -u https://transportadmin:transportadminpw@localhost:8054 --caname ca-transport -M ${PWD}/organizations/peerOrganizations/transport.bcfm.com/users/Admin@transport.bcfm.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/transport/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/transport.bcfm.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/transport.bcfm.com/users/Admin@transport.bcfm.com/msp/config.yaml

}

function createOrderer() {

  infoln "Enroll the CA admin"
  sleep 2
  mkdir -p organizations/ordererOrganizations/bcfm.com

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/ordererOrganizations/bcfm.com
  #  rm -rf $FABRIC_CA_CLIENT_HOME/fabric-ca-client-config.yaml
  #  rm -rf $FABRIC_CA_CLIENT_HOME/msp

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:13054 --caname ca-orderer --tls.certfiles ${PWD}/organizations/fabric-ca/ordererUA/tls-cert.pem
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-13054-ca-orderer.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-13054-ca-orderer.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-13054-ca-orderer.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-13054-ca-orderer.pem
    OrganizationalUnitIdentifier: orderer' >${PWD}/organizations/ordererOrganizations/bcfm.com/msp/config.yaml

  infoln "Register orderer"
  set -x
  fabric-ca-client register --caname ca-orderer --id.name orderer --id.secret ordererpw --id.type orderer --tls.certfiles ${PWD}/organizations/fabric-ca/ordererUA/tls-cert.pem
  { set +x; } 2>/dev/null


  infoln "Register orderer2"
  set -x
  fabric-ca-client register --caname ca-orderer --id.name orderer2 --id.secret ordererpw --id.type orderer --tls.certfiles  ${PWD}/organizations/fabric-ca/ordererUA/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Register orderer3"
  set -x
  fabric-ca-client register --caname ca-orderer --id.name orderer3 --id.secret ordererpw --id.type orderer --tls.certfiles  ${PWD}/organizations/fabric-ca/ordererUA/tls-cert.pem
  { set +x; } 2>/dev/null


  infoln "Register orderer4"
  set -x
  fabric-ca-client register --caname ca-orderer --id.name orderer4 --id.secret ordererpw --id.type orderer --tls.certfiles  ${PWD}/organizations/fabric-ca/ordererUA/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Register orderer5"
  set -x
  fabric-ca-client register --caname ca-orderer --id.name orderer5 --id.secret ordererpw --id.type orderer --tls.certfiles  ${PWD}/organizations/fabric-ca/ordererUA/tls-cert.pem
  { set +x; } 2>/dev/null




  infoln "Register the orderer admin"
  set -x
  fabric-ca-client register --caname ca-orderer --id.name ordererAdmin --id.secret ordererAdminpw --id.type admin --tls.certfiles ${PWD}/organizations/fabric-ca/ordererUA/tls-cert.pem
  { set +x; } 2>/dev/null

  mkdir -p organizations/ordererOrganizations/bcfm.com/orderers
  mkdir -p organizations/ordererOrganizations/bcfm.com/orderers/bcfm.com

  mkdir -p organizations/ordererOrganizations/bcfm.com/orderers/orderer.bcfm.com

  infoln "Generate the orderer msp"
  set -x
  fabric-ca-client enroll -u https://orderer:ordererpw@localhost:13054 --caname ca-orderer -M ${PWD}/organizations/ordererOrganizations/bcfm.com/orderers/orderer.bcfm.com/msp --csr.hosts orderer.bcfm.com --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/ordererUA/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/ordererOrganizations/bcfm.com/msp/config.yaml ${PWD}/organizations/ordererOrganizations/bcfm.com/orderers/orderer.bcfm.com/msp/config.yaml

  infoln "Generate the orderer-tls certificates"
  set -x
  fabric-ca-client enroll -u https://orderer:ordererpw@localhost:13054 --caname ca-orderer -M ${PWD}/organizations/ordererOrganizations/bcfm.com/orderers/orderer.bcfm.com/tls --enrollment.profile tls --csr.hosts orderer.bcfm.com --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/ordererUA/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/ordererOrganizations/bcfm.com/orderers/orderer.bcfm.com/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/bcfm.com/orderers/orderer.bcfm.com/tls/ca.crt
  cp ${PWD}/organizations/ordererOrganizations/bcfm.com/orderers/orderer.bcfm.com/tls/signcerts/* ${PWD}/organizations/ordererOrganizations/bcfm.com/orderers/orderer.bcfm.com/tls/server.crt
  cp ${PWD}/organizations/ordererOrganizations/bcfm.com/orderers/orderer.bcfm.com/tls/keystore/* ${PWD}/organizations/ordererOrganizations/bcfm.com/orderers/orderer.bcfm.com/tls/server.key

  mkdir -p ${PWD}/organizations/ordererOrganizations/bcfm.com/orderers/orderer.bcfm.com/msp/tlscacerts
  cp ${PWD}/organizations/ordererOrganizations/bcfm.com/orderers/orderer.bcfm.com/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/bcfm.com/orderers/orderer.bcfm.com/msp/tlscacerts/tlsca.bcfm.com-cert.pem

  mkdir -p ${PWD}/organizations/ordererOrganizations/bcfm.com/msp/tlscacerts
  cp ${PWD}/organizations/ordererOrganizations/bcfm.com/orderers/orderer.bcfm.com/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/bcfm.com/msp/tlscacerts/tlsca.bcfm.com-cert.pem

  mkdir -p organizations/ordererOrganizations/bcfm.com/users
  mkdir -p organizations/ordererOrganizations/bcfm.com/users/Admin@bcfm.com


  # -----------------------------------------------------------------------
  #  Orderer 2

  mkdir -p organizations/ordererOrganizations/bcfm.com/orderers/orderer2.bcfm.com

  infoln "Generate the orderer2 msp"
  set -x
  fabric-ca-client enroll -u https://orderer:ordererpw@localhost:13054 --caname ca-orderer -M ${PWD}/organizations/ordererOrganizations/bcfm.com/orderers/orderer2.bcfm.com/msp --csr.hosts orderer2.bcfm.com --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/ordererUA/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/ordererOrganizations/bcfm.com/msp/config.yaml ${PWD}/organizations/ordererOrganizations/bcfm.com/orderers/orderer2.bcfm.com/msp/config.yaml

  infoln "Generate the orderer2-tls certificates"
  set -x
  fabric-ca-client enroll -u https://orderer:ordererpw@localhost:13054 --caname ca-orderer -M ${PWD}/organizations/ordererOrganizations/bcfm.com/orderers/orderer2.bcfm.com/tls --enrollment.profile tls --csr.hosts orderer2.bcfm.com --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/ordererUA/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/ordererOrganizations/bcfm.com/orderers/orderer2.bcfm.com/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/bcfm.com/orderers/orderer2.bcfm.com/tls/ca.crt
  cp ${PWD}/organizations/ordererOrganizations/bcfm.com/orderers/orderer2.bcfm.com/tls/signcerts/* ${PWD}/organizations/ordererOrganizations/bcfm.com/orderers/orderer2.bcfm.com/tls/server.crt
  cp ${PWD}/organizations/ordererOrganizations/bcfm.com/orderers/orderer2.bcfm.com/tls/keystore/* ${PWD}/organizations/ordererOrganizations/bcfm.com/orderers/orderer2.bcfm.com/tls/server.key

  mkdir -p ${PWD}/organizations/ordererOrganizations/bcfm.com/orderers/orderer2.bcfm.com/msp/tlscacerts
  cp ${PWD}/organizations/ordererOrganizations/bcfm.com/orderers/orderer2.bcfm.com/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/bcfm.com/orderers/orderer2.bcfm.com/msp/tlscacerts/tlsca.bcfm.com-cert.pem

  mkdir -p ${PWD}/organizations/ordererOrganizations/bcfm.com/msp/tlscacerts
  cp ${PWD}/organizations/ordererOrganizations/bcfm.com/orderers/orderer2.bcfm.com/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/bcfm.com/msp/tlscacerts/tlsca.bcfm.com-cert.pem



  # -----------------------------------------------------------------------
  #  Orderer 3

  mkdir -p organizations/ordererOrganizations/bcfm.com/orderers/orderer3.bcfm.com

  infoln "Generate the orderer3 msp"
  set -x
  fabric-ca-client enroll -u https://orderer:ordererpw@localhost:13054 --caname ca-orderer -M ${PWD}/organizations/ordererOrganizations/bcfm.com/orderers/orderer3.bcfm.com/msp --csr.hosts orderer3.bcfm.com --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/ordererUA/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/ordererOrganizations/bcfm.com/msp/config.yaml ${PWD}/organizations/ordererOrganizations/bcfm.com/orderers/orderer3.bcfm.com/msp/config.yaml

  infoln "Generate the orderer3-tls certificates"
  set -x
  fabric-ca-client enroll -u https://orderer:ordererpw@localhost:13054 --caname ca-orderer -M ${PWD}/organizations/ordererOrganizations/bcfm.com/orderers/orderer3.bcfm.com/tls --enrollment.profile tls --csr.hosts orderer3.bcfm.com --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/ordererUA/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/ordererOrganizations/bcfm.com/orderers/orderer3.bcfm.com/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/bcfm.com/orderers/orderer3.bcfm.com/tls/ca.crt
  cp ${PWD}/organizations/ordererOrganizations/bcfm.com/orderers/orderer3.bcfm.com/tls/signcerts/* ${PWD}/organizations/ordererOrganizations/bcfm.com/orderers/orderer3.bcfm.com/tls/server.crt
  cp ${PWD}/organizations/ordererOrganizations/bcfm.com/orderers/orderer3.bcfm.com/tls/keystore/* ${PWD}/organizations/ordererOrganizations/bcfm.com/orderers/orderer3.bcfm.com/tls/server.key

  mkdir -p ${PWD}/organizations/ordererOrganizations/bcfm.com/orderers/orderer3.bcfm.com/msp/tlscacerts
  cp ${PWD}/organizations/ordererOrganizations/bcfm.com/orderers/orderer3.bcfm.com/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/bcfm.com/orderers/orderer3.bcfm.com/msp/tlscacerts/tlsca.bcfm.com-cert.pem

  mkdir -p ${PWD}/organizations/ordererOrganizations/bcfm.com/msp/tlscacerts
  cp ${PWD}/organizations/ordererOrganizations/bcfm.com/orderers/orderer3.bcfm.com/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/bcfm.com/msp/tlscacerts/tlsca.bcfm.com-cert.pem




  # -----------------------------------------------------------------------
  #  Orderer 4

  mkdir -p organizations/ordererOrganizations/bcfm.com/orderers/orderer4.bcfm.com

  infoln "Generate the orderer4 msp"
  set -x
  fabric-ca-client enroll -u https://orderer:ordererpw@localhost:13054 --caname ca-orderer -M ${PWD}/organizations/ordererOrganizations/bcfm.com/orderers/orderer4.bcfm.com/msp --csr.hosts orderer4.bcfm.com --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/ordererUA/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/ordererOrganizations/bcfm.com/msp/config.yaml ${PWD}/organizations/ordererOrganizations/bcfm.com/orderers/orderer4.bcfm.com/msp/config.yaml

  infoln "Generate the orderer4-tls certificates"
  set -x
  fabric-ca-client enroll -u https://orderer:ordererpw@localhost:13054 --caname ca-orderer -M ${PWD}/organizations/ordererOrganizations/bcfm.com/orderers/orderer4.bcfm.com/tls --enrollment.profile tls --csr.hosts orderer4.bcfm.com --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/ordererUA/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/ordererOrganizations/bcfm.com/orderers/orderer4.bcfm.com/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/bcfm.com/orderers/orderer4.bcfm.com/tls/ca.crt
  cp ${PWD}/organizations/ordererOrganizations/bcfm.com/orderers/orderer4.bcfm.com/tls/signcerts/* ${PWD}/organizations/ordererOrganizations/bcfm.com/orderers/orderer4.bcfm.com/tls/server.crt
  cp ${PWD}/organizations/ordererOrganizations/bcfm.com/orderers/orderer4.bcfm.com/tls/keystore/* ${PWD}/organizations/ordererOrganizations/bcfm.com/orderers/orderer4.bcfm.com/tls/server.key

  mkdir -p ${PWD}/organizations/ordererOrganizations/bcfm.com/orderers/orderer4.bcfm.com/msp/tlscacerts
  cp ${PWD}/organizations/ordererOrganizations/bcfm.com/orderers/orderer4.bcfm.com/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/bcfm.com/orderers/orderer4.bcfm.com/msp/tlscacerts/tlsca.bcfm.com-cert.pem

  mkdir -p ${PWD}/organizations/ordererOrganizations/bcfm.com/msp/tlscacerts
  cp ${PWD}/organizations/ordererOrganizations/bcfm.com/orderers/orderer4.bcfm.com/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/bcfm.com/msp/tlscacerts/tlsca.bcfm.com-cert.pem




  # -----------------------------------------------------------------------
  #  Orderer 5

  mkdir -p organizations/ordererOrganizations/bcfm.com/orderers/orderer5.bcfm.com

  infoln "Generate the orderer5 msp"
  set -x
  fabric-ca-client enroll -u https://orderer:ordererpw@localhost:13054 --caname ca-orderer -M ${PWD}/organizations/ordererOrganizations/bcfm.com/orderers/orderer5.bcfm.com/msp --csr.hosts orderer5.bcfm.com --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/ordererUA/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/ordererOrganizations/bcfm.com/msp/config.yaml ${PWD}/organizations/ordererOrganizations/bcfm.com/orderers/orderer5.bcfm.com/msp/config.yaml

  infoln "Generate the orderer5-tls certificates"
  set -x
  fabric-ca-client enroll -u https://orderer:ordererpw@localhost:13054 --caname ca-orderer -M ${PWD}/organizations/ordererOrganizations/bcfm.com/orderers/orderer5.bcfm.com/tls --enrollment.profile tls --csr.hosts orderer5.bcfm.com --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/ordererUA/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/ordererOrganizations/bcfm.com/orderers/orderer5.bcfm.com/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/bcfm.com/orderers/orderer5.bcfm.com/tls/ca.crt
  cp ${PWD}/organizations/ordererOrganizations/bcfm.com/orderers/orderer5.bcfm.com/tls/signcerts/* ${PWD}/organizations/ordererOrganizations/bcfm.com/orderers/orderer5.bcfm.com/tls/server.crt
  cp ${PWD}/organizations/ordererOrganizations/bcfm.com/orderers/orderer5.bcfm.com/tls/keystore/* ${PWD}/organizations/ordererOrganizations/bcfm.com/orderers/orderer5.bcfm.com/tls/server.key

  mkdir -p ${PWD}/organizations/ordererOrganizations/bcfm.com/orderers/orderer5.bcfm.com/msp/tlscacerts
  cp ${PWD}/organizations/ordererOrganizations/bcfm.com/orderers/orderer5.bcfm.com/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/bcfm.com/orderers/orderer5.bcfm.com/msp/tlscacerts/tlsca.bcfm.com-cert.pem

  mkdir -p ${PWD}/organizations/ordererOrganizations/bcfm.com/msp/tlscacerts
  cp ${PWD}/organizations/ordererOrganizations/bcfm.com/orderers/orderer5.bcfm.com/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/bcfm.com/msp/tlscacerts/tlsca.bcfm.com-cert.pem



  infoln "Generate the admin msp"
  set -x
  fabric-ca-client enroll -u https://ordererAdmin:ordererAdminpw@localhost:13054 --caname ca-orderer -M ${PWD}/organizations/ordererOrganizations/bcfm.com/users/Admin@bcfm.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/ordererUA/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/ordererOrganizations/bcfm.com/msp/config.yaml ${PWD}/organizations/ordererOrganizations/bcfm.com/users/Admin@bcfm.com/msp/config.yaml

}
