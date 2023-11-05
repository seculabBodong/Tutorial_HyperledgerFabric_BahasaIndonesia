export FABRIC_CFG_PATH=${PWD}/artifacts/channel/config/
export CHANNEL_NAME=mychannel
# ENV
. envVar.sh

CHANNEL_NAME="mychannel"
CC_RUNTIME_LANGUAGE="node"
VERSION_PKG="1.0"
VERSION="1"
CC_SRC_PATH="./artifacts/chaincode-javascript/"
CC_NAME="basic"

packageChaincode(){
    rm -rf ${CC_NAME}.tar.gz
    setGlobalsForPeer0Org1
    peer lifecycle chaincode package ${CC_NAME}.tar.gz \
    --path ${CC_SRC_PATH} --lang ${CC_RUNTIME_LANGUAGE} \
    --label ${CC_NAME}_${VERSION_PKG}
    echo "===================== Chaincode is packaged on peer0.org1 ===================== "
}

installChaincode(){
    setGlobalsForPeer0Org1
    peer lifecycle chaincode install ${CC_NAME}.tar.gz
    echo "===================== Chaincode is installed on peer0.org1 ===================== "
    
    setGlobalsForPeer0Org2
    peer lifecycle chaincode install ${CC_NAME}.tar.gz
    echo "===================== Chaincode is installed on peer0.org2 ===================== "

}

queryInstalled(){
    # setGlobals 1
    setGlobalsForPeer0Org1
    
    peer lifecycle chaincode queryinstalled >&log.txt
    cat log.txt
    PKGID=$(sed -n "/${CC_NAME}_${VERSION_PKG}/{s/^Package ID: //; s/, Label:.*$//; p;}" log.txt)
    echo PackageID is ${PKGID}
    echo "===================== Query installed successful on peer0.org1 on channel ===================== "
}

approveForMyOrg1(){
    setGlobalsForPeer0Org1

    peer lifecycle chaincode approveformyorg -o localhost:7050 \
    --ordererTLSHostnameOverride orderer.example.com \
    --channelID $CHANNEL_NAME --name ${CC_NAME} \
    --version ${VERSION_PKG} --package-id ${PKGID} --sequence ${VERSION} --tls \
    --cafile $ORDERER_CA --init-required
    echo "===================== chaincode approved from org 1 ===================== "
}

approveForMyOrg2(){
    setGlobalsForPeer0Org2

    peer lifecycle chaincode approveformyorg -o localhost:7050 \
    --ordererTLSHostnameOverride orderer.example.com \
    --channelID $CHANNEL_NAME --name ${CC_NAME} \
    --version ${VERSION_PKG} --package-id ${PKGID} --sequence ${VERSION} --tls $CORE_PEER_TLS_ENABLED\
    --cafile $ORDERER_CA --init-required
    echo "===================== chaincode approved from org 2 ===================== "
}
checkCommitReadyness(){ 
    setGlobalsForPeer0Org1

    peer lifecycle chaincode checkcommitreadiness \
    --channelID $CHANNEL_NAME --name ${CC_NAME} \
    --version ${VERSION_PKG} --sequence ${VERSION} --tls $CORE_PEER_TLS_ENABLED\
    --cafile $ORDERER_CA --output json --init-required
    echo "===================== checking commit readyness from org  ===================== "
}
commitChaincodeDefination(){
    setGlobalsForPeer0Org1
    set -x
    peer lifecycle chaincode commit -o localhost:7050 \
    --ordererTLSHostnameOverride orderer.example.com \
    --channelID $CHANNEL_NAME --name ${CC_NAME} --version ${VERSION_PKG} --sequence ${VERSION} \
    --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA \
    --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_ORG1_CA \
    --peerAddresses localhost:9051 --tlsRootCertFiles $PEER0_ORG2_CA \
    --init-required
    set +x
   
}
queryCommitted(){
    setGlobalsForPeer0Org1
    peer lifecycle chaincode querycommitted --channelID $CHANNEL_NAME --name ${CC_NAME}
    
}
chaincodeInvokeInit(){
    setGlobalsForPeer0Org1
    peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com \
    --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA -C $CHANNEL_NAME -n ${CC_NAME} \
    --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_ORG1_CA \
    --peerAddresses localhost:9051 --tlsRootCertFiles $PEER0_ORG2_CA \
    --isInit -c '{"Args":[]}' 

}
chaincodeInvoke() {
    setGlobalsForPeer0Org1

    ## Init ledger
    peer chaincode invoke -o localhost:7050 \
        --ordererTLSHostnameOverride orderer.example.com \
        --tls $CORE_PEER_TLS_ENABLED \
        --cafile $ORDERER_CA \
        -C $CHANNEL_NAME -n ${CC_NAME} \
        --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_ORG1_CA \
        --peerAddresses localhost:9051 --tlsRootCertFiles $PEER0_ORG2_CA \
        -c '{"function":"InitLedger","Args":[]}'
}
chaincodeQuery(){
    setGlobalsForPeer0Org1
    
    peer chaincode query -C $CHANNEL_NAME -n ${CC_NAME} -c '{"function":"ReadAsset","Args":["random123"]}'>&output.json
    
    cat output.json
}

packageChaincode
installChaincode
queryInstalled
export PKGID=$(sed -n "/${CC_NAME}_${VERSION_PKG}/{s/^Package ID: //; s/, Label:.*$//; p;}" log.txt)
echo ${PKGID}
approveForMyOrg1
checkCommitReadyness
approveForMyOrg2
checkCommitReadyness
commitChaincodeDefination
queryCommitted
chaincodeInvokeInit
sleep 5
chaincodeInvoke
sleep 3
chaincodeQuery
