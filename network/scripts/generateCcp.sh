
#!/bin/bash

function one_line_pem {
    echo "`awk 'NF {sub(/\\n/, ""); printf "%s\\\\\\\n",$0;}' $1`"
}

function json_ccp {
    local PP=$(one_line_pem $4)
    local CP=$(one_line_pem $5)
    sed -e "s/\${ORG}/$1/" \
        -e "s/\${P0PORT}/$2/" \
        -e "s/\${CAPORT}/$3/" \
        -e "s/\${ORG_NAME}/$6/" \
        -e "s#\${PEERPEM}#$PP#" \
        -e "s#\${CAPEM}#$CP#" \
        extra/ccp-template.json
}


ORG=ElectionCommission
ORG_NAME=election_commission
P0PORT=8051
CAPORT=9054
PEERPEM=ca/organizations/election_commission/peers/peer0.election_commission/tls/ca.crt
CAPEM=ca/organizations/election_commission/ca/election_commission-cert.pem

echo "$(json_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM $ORG_NAME)" > connection-profiles/connection-election_commission.json








ORG=MyParty
ORG_NAME=my_party
P0PORT=7051
CAPORT=7054
PEERPEM=ca/organizations/my_party/tlsca/tlsca.my_party-cert.pem
CAPEM=ca/organizations/my_party/ca/ca.my_party-cert.pem

echo "$(json_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM $ORG_NAME)" > connection-profiles/connection-my_party.json









