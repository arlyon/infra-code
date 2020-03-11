#!/bin/bash

if [ $# -ne 4 ]; then
    echo "Usage: $0 <CLIENT_KEY_NAME> <NAMESPACE> <HELM_RELEASE> <SERVICE_IP>"
    exit
fi

KEY_NAME=$1
NAMESPACE=$2
HELM_RELEASE=$3
SERVICE_IP=$4
POD_NAME=$(kubectl get pods -n "$NAMESPACE" -l "app=openvpn,release=$HELM_RELEASE" -o jsonpath='{.items[0].metadata.name}')
SERVICE_NAME=$(kubectl get svc -n "$NAMESPACE" -l "app=openvpn,release=$HELM_RELEASE" -o jsonpath='{.items[0].metadata.name}')

kubectl -n "$NAMESPACE" exec -it "$POD_NAME" /etc/openvpn/setup/newClientCert.sh "$KEY_NAME" "$SERVICE_IP"
kubectl -n "$NAMESPACE" exec -it "$POD_NAME" cat "/etc/openvpn/certs/pki/$KEY_NAME.ovpn" >"$KEY_NAME.ovpn"
