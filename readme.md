# InfraCode

## Traefik

This project uses traefik as the reverse proxy.

```
helm install traefik traefik/traefik --values config/traefik-values.yaml
```

Then, to enable the dashboard we will need to create an
ingress route with basic auth.

```
./scripts/upload_password.sh
kubectl apply -f kubernetes/traefik-dashboard.yaml
```

## ExternalDNS

ExternalDNS is installed into the main namespace.

```
helm install external-dns stable/external-dns --values=config/external-dns-values.yaml
```

## Guacamole

You can use this helm chart:

```
kubectl create namespace guacamole
cd charts/guacamole-helm-chart
helm install gaucamole . --values=../../config/guacamole-values.yaml --namespace=guacamole
```

## OpenVPN

```
kubectl create namespace openvpn
helm repo add stable http://storage.googleapis.com/kubernetes-charts
helm install stable/openvpn
```