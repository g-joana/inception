#!/bin/bash

if [ ! -f "/etc/ssl/private/cert.key" ] || [ ! -f "/etc/ssl/certs/cert.pem" ]; then
    rm -f /etc/ssl/private/cert.key /etc/ssl/certs/cert.pem
    openssl ecparam -name prime256v1 -genkey -noout -out /etc/ssl/private/cert.key
    openssl req -new -x509 -key /etc/ssl/private/cert.key -out /etc/ssl/certs/cert.pem -days 365 -subj "/C=BR/ST=RJ/L=Rio de Janeiro/O=42/OU=Rio/CN=${WP_HOST}"
fi
