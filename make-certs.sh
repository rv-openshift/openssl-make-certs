#!/bin/bash

echo "This will create a root-CA, sub-CA and the host-CA"

mkdir -p myCA/rootCA/newcerts myCA/subCA/newcerts
cd myCA
touch rootCA/index.txt subCA/index.txt
echo 1000 > rootCA/serial && echo 1000 > subCA/serial

cat <<EOT >> root-ca.cnf
[ req ]
default_bits = 4096
prompt = no
default_md = sha256
distinguished_name = dn

[ dn ]
C = CA
ST = Toronto
L = Toronto
O = Ric
OU = IT
emailAddress = venerayan@gmail.com
CN = ric-io

[ v3_ca ]
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid:always,issuer:always
basicConstraints = critical,CA:true
keyUsage = keyCertSign, cRLSign
EOT

cat <<EOT >> sub-ca.cnf
[ req ]
default_bits = 4096
prompt = no
default_md = sha256
distinguished_name = dn

[ dn ]
C = CA
ST = Toronto
L = Toronto
O = Ric
OU = IT
emailAddress = venerayan@gmail.com
CN = sub-ric-io

[ v3_ca ]
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid:always,issuer:always
basicConstraints = critical,CA:true,pathlen:0
keyUsage = keyCertSign, cRLSign
EOT

# create root-ca, run this separate if you want passphrase
openssl genrsa -out rootCA/rootCA.key 4096

openssl req -x509 -new -nodes -key rootCA/rootCA.key -sha256 -days 3650 -out rootCA/rootCA.crt -config root-ca.cnf

if [ -s rootCA/rootCA.crt ]; then
   echo "created rootCA/rootCA.crt"
else
   echo "***error did not create rootCA/rootCA.crt or it is empty!"
   exit 1
fi

# create sub-ca
openssl genrsa -out subCA/subCA.key 4096

openssl req -new -key subCA/subCA.key -out subCA/subCA.csr -config sub-ca.cnf

openssl x509 -req -in subCA/subCA.csr -CA rootCA/rootCA.crt -CAkey rootCA/rootCA.key -CAcreateserial -days 3650 -out subCA/subCA.crt -sha256 -extensions v3_ca

if [ -s subCA/subCA.crt ]; then
   echo "created subCA/subCA.crt"
else
   echo "***error did not create subCA/subCA.crt or it is empty!"
   exit 1
fi

cat <<EOT >> host.cnf
[ req ]
default_bits = 4096
prompt = no
default_md = sha256
req_extensions = v3_req
distinguished_name = dn

[ dn ]
C = CA
ST = Toronto
L = Toronto
O = Ric
OU = IT
emailAddress = venerayan@gmail.com
CN = gitlab.ric.io

[ v3_req ]
keyUsage = keyEncipherment, dataEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names

[alt_names]
DNS.1 = gitlab.ric.io
EOT

openssl genrsa -out gitlab.ric.io.key 4096

openssl req -new -key gitlab.ric.io.key -out gitlab.ric.io.csr -config host.cnf

cat <<EOT >> host-sub.cnf
[ v3_server ]
basicConstraints = CA:FALSE
keyUsage = digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names

[alt_names]
DNS.1 = gitlab.ric.io
EOT

# create host
openssl x509 -req -in gitlab.ric.io.csr -CA subCA/subCA.crt -CAkey subCA/subCA.key -CAcreateserial -out gitlab.ric.io.crt -days 365 -sha256 -extensions v3_server -extfile host-sub.cnf

if [ -s gitlab.ric.io.crt ]; then
   echo "created gitlab.ric.io.crt"
else
   echo "***error did not create gitlab.ric.io.crt or it is empty!"
   exit 1
fi
