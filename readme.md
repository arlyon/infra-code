# InfraCode

## Traefik

This project uses traefik as the reverse proxy.

```
helm install traefik traefik/traefik --values config/traefik-values.yaml
```

Then, to enable the dashboard we will need to create an
ingress route with basic auth.

```
htpasswd -c ./auth arlyon
kubectl create secret generic auth-secret --from-file auth
kubectl apply -f kubernetes/traefik-dashboard.yaml
```

## ExternalDNS

ExternalDNS is installed into the main namespace.

```
helm install external-dns stable/external-dns --values=config/external-dns-values.yaml
```
