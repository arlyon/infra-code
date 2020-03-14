# InfraCode

## Services

### Traefik

This project uses traefik as the reverse proxy.
To enable the dashboard we will need to create
a username and password for the basic auth:

```
./scripts/upload_password.sh arlyon
```

### ExternalDNS

ExternalDNS is used alongside traefik to easily
provision DNS entries for apps routed with traefik.
It is currently connected to cloudflare.

### Guacamole

Guacamole is used to provide remote desktop access
to the cluster.

### OpenVPN

OpenVPN provides secure VPN access to the cluster
(and by extension home network). Once the instance
is set up, you can provision certificates using the
script:

```bash
./scripts/create_openvpn_cert.sh phone openvpn openvpn vpn.arlyon.dev
```

## Terraform

Terraform is used to provision the required infrastructure.
It depends on the `kubectl` plugin so download it:

```
mkdir -p ~/.terraform.d/plugins && \
    curl -Ls https://api.github.com/repos/gavinbunney/terraform-provider-kubectl/releases/latest \
    | jq -r ".assets[] | select(.browser_download_url | contains(\"$(uname -s | tr A-Z a-z)\")) | select(.browser_download_url | contains(\"amd64\")) | .browser_download_url" \
    | xargs -n 1 curl -Lo ~/.terraform.d/plugins/terraform-provider-kubectl && \
    chmod +x ~/.terraform.d/plugins/terraform-provider-kubectl
```

Then you will need to get some gcp service account credentials
to pull the state from: https://cloud.google.com/docs/authentication/production.
Place this in `terraform/gcp-credentials.json`. Then:

```
cd terraform
terraform init
terraform apply .
```

## Infrastructure

Currently this is deployed on a 3-node k3s cluster running on alpine linux,
using high-availability mode with an embedded DB. On k3s, it is decided that
`metallb` will be used over the built-in `servicelb`.

```bash
# on the master node
K3S_TOKEN=$TOKEN ./k3s.sh --cluster-init --no-deploy traefik --no-deploy servicelb

# on the other nodes
K3S_TOKEN=$TOKEN ./k3s.sh --server https://$IP_ADDR:6443
```

> Note: that on alpine linux the defaults are set to 4096 (FAR TOO LOW).
> You can change the values in /etc/sysctl.d/00_alpine.conf!