# This compose file will start a Hyperledger Fabric 1.0 MVE, including
# * 1 ca
# * 1 orderer
# * 4 peers in 2 orgs
# * cli for testing
# assigned fixed ip addreess to all containers

version: '2.0'

services:
  ca:
    image: hyperledger/fabric-ca
    container_name: fabric-ca
    hostname: ca
  #  command: /go/src/github.com/hyperledger/fabric-ca/bin/ca server start -ca testdata/ec.pem -ca-key testdata/ec-key.pem -config testdata/testconfig.json
    ports:
      - "7054:7054"
    networks:
      default:
        ipv4_address: 172.18.0.2
    command: fabric-ca-server start -b admin:adminpw
    
  orderer.example.com:  # There  can be multiple orderers
    extends:
      file: docker-compose-base.yaml
      service: orderer.example.com
    networks:
      default:
        ipv4_address: 172.18.0.3

  peer0.org1.example.com:
    extends:
      file: docker-compose-base.yaml
      service: peer0.org1.example.com
    networks:
      default:
        ipv4_address: 172.18.0.4

  peer1.org1.example.com:
    extends:
      file: docker-compose-base.yaml
      service: peer1.org1.example.com
    networks:
       default:
        ipv4_address: 172.18.0.5

  peer0.org2.example.com:
    extends:
      file: docker-compose-base.yaml
      service: peer0.org2.example.com
    networks:
      default:
        ipv4_address: 172.18.0.6

  peer1.org2.example.com:
    extends:
      file: docker-compose-base.yaml
      service: peer1.org2.example.com
    networks:
      default:
        ipv4_address: 172.18.0.7

  cli:
    container_name: fabric-cli
    hostname: fabric-cli
    image: hyperledger/fabric-tools
    tty: true
    environment:
      #- GOPATH=/opt/gopath
      - CORE_PEER_ID=fabric-cli
      - CORE_LOGGING_LEVEL=DEBUG
      - CORE_PEER_ADDRESS=peer0.org1.example.com:7051 # default to operate on peer0.org1
      - CORE_PEER_LOCALMSPID=Org1MSP
      - CORE_PEER_TLS_ENABLED=true  # to enable TLS, change to true
      - CORE_PEER_TLS_CERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/server.crt
      - CORE_PEER_TLS_KEY_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/server.key
      - CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
      - CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
    volumes:
        - ./e2e_cli/examples:/opt/gopath/src/github.com/hyperledger/fabric/examples
        - ./e2e_cli/crypto-config:/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/
        - ./scripts:/opt/gopath/src/github.com/hyperledger/fabric/peer/scripts/
        - ./e2e_cli/channel-artifacts:/opt/gopath/src/github.com/hyperledger/fabric/peer/channel-artifacts
        - ./e2e_cli/configtx.yaml:/etc/hyperledger/fabric/configtx.yaml
        - ./e2e_cli/crypto-config.yaml:/etc/hyperledger/fabric/crypto-config.yaml
    depends_on:
      - orderer.example.com
      - peer0.org1.example.com
      - peer1.org1.example.com
      - peer0.org2.example.com
      - peer1.org2.example.com
    links:
      - orderer.example.com
      - peer0.org1.example.com
      - peer1.org1.example.com
      - peer0.org2.example.com
      - peer1.org2.example.com
    working_dir: /opt/gopath/src/github.com/hyperledger/fabric/peer
    command: bash -c 'while true; do sleep 20170504; done'
    networks:
      default:
        ipv4_address: 172.18.0.8

networks:
  default:
    driver: bridge
    ipam:
      config:
      - subnet: 172.18.0.0/24
