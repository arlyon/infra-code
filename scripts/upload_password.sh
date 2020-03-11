#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usage: $0 <USERNAME>"
    exit
fi

htpasswd -c ./auth $1
kubectl create secret generic auth-secret --from-file auth
rm ./auth
