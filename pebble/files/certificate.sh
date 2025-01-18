#!/bin/sh
set -eux

# Self-signed CA key and certificate
# openssl genrsa -out root-key.pem 2048
# openssl req -new -x509 -key root-key.pem -subj "/CN=Pebble Helm Chart self-signed CA" -days 3650 -out root-cert.pem

CA_KEY=/input/root-key.pem
CA_CERT=/input/root-cert.pem

CERT_DIR=/output/localhost

# Convert "a,a.b,a.b.c" to "DNS:a, DNS:a.b, DNS:a.b.c, "
SAN_DNS=`echo "$@" | awk -F, '{for(i=1; i<=NF; i++) {printf "DNS:" $i ", "}}'`

# Server certificate key
if [ ! -f "$CERT_DIR/key.pem" ]; then
    openssl genrsa -out "$CERT_DIR/key.pem" 2048
fi

# Server certificate
openssl req -new -key "$CERT_DIR/key.pem" -subj "/CN=localhost" -addext "subjectAltName = $SAN_DNS IP:127.0.0.1" -addext "extendedKeyUsage = serverAuth,clientAuth" -out "$CERT_DIR/req.csr"
openssl x509 -CAkey "$CA_KEY" -CA "$CA_CERT" -req -copy_extensions copy -in "$CERT_DIR/req.csr" -days 3650 -out "$CERT_DIR/cert.pem"
