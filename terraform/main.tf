terraform {
  backend "gcs" {
    bucket  = "tf-state-hermes"
    prefix  = "terraform/state"
    credentials = "gcp-credentials.json"
  }
}

provider "kubectl" {
  config_context_cluster = "minikube-hermes"
}

data "helm_repository" "stable" {
  name = "stable"
  url  = "http://storage.googleapis.com/kubernetes-charts"
}

data "helm_repository" "traefik" {
  name = "traefik"
  url  = "https://containous.github.io/traefik-helm-chart"
}

resource "kubernetes_namespace" "guacamole" {
  metadata {
    name = "guacamole"
  }
}

resource "kubernetes_namespace" "openvpn" {
  metadata {
    name = "openvpn"
  }
}

resource "kubernetes_namespace" "minio" {
  metadata {
    name = "minio"
  }
}

resource "helm_release" "traefik" {
  name       = "traefik"
  repository = data.helm_repository.traefik.metadata[0].name
  chart      = "traefik"
  version    = var.traefik_version
  values     = ["${file("../config/traefik-values.yaml")}"]
}

resource "helm_release" "external-dns" {
  name       = "external-dns"
  repository = data.helm_repository.stable.metadata[0].name
  chart      = "external-dns"
  version    = var.external_dns_version
  values     = ["${file("../config/external-dns-values.yaml")}"]
}

resource "helm_release" "minio" {
  name       = "minio"
  repository = data.helm_repository.stable.metadata[0].name
  chart      = "minio"
  version    = var.minio_version
  namespace  = kubernetes_namespace.minio.metadata[0].name
}

resource "helm_release" "openvpn" {
  name       = "openvpn"
  repository = data.helm_repository.stable.metadata[0].name
  chart      = "openvpn"
  version    = var.openvpn_version
  namespace  = kubernetes_namespace.openvpn.metadata[0].name
  values     = ["${file("../config/openvpn-values.yaml")}"]
}

resource "helm_release" "guacamole" {
  name       = "guacamole"
  repository = "../charts"
  chart      = "guacamole"
  version    = var.guacamole_version
  namespace  = kubernetes_namespace.guacamole.metadata[0].name
  values     = ["${file("../config/guacamole-values.yaml")}"]
}

resource "kubernetes_persistent_volume" "guacamole" {
  metadata {
    name = "guacamole"
    labels = {
      app = "guacamole"
    }
  }
  spec {
    storage_class_name = "nfs-client"
    capacity = {
      storage = "10Gi"
    }
    access_modes = ["ReadWriteOnce"]
    persistent_volume_source {
      host_path {
        path = "/mnt/guac/data"
      }
    }
  }
}

resource "kubernetes_persistent_volume" "guacamole-mysql" {
  metadata {
    name = "guacamole-mysql"
    labels = {
      app = "guacamole"
    }
  }
  spec {
    storage_class_name = "nfs-client"
    capacity = {
      storage = "10Gi"
    }
    access_modes = ["ReadWriteOnce"]
    persistent_volume_source {
      host_path {
        path = "/mnt/guac-mysql/data"
      }
    }
  }
}

resource "kubectl_manifest" "traefik-dashboard" {
  yaml_body = file("../kubernetes/traefik-dashboard.yaml")
  depends_on = [helm_release.traefik]
}

resource "kubectl_manifest" "traefik-guacamole" {
  yaml_body = file("../kubernetes/traefik-guacamole.yaml")
  depends_on = [helm_release.traefik, helm_release.guacamole]
}

resource "kubectl_manifest" "traefik-minio" {
  yaml_body = file("../kubernetes/traefik-minio.yaml")
  depends_on = [helm_release.traefik, helm_release.minio]
}

resource "kubectl_manifest" "traefik-openvpn" {
  yaml_body = file("../kubernetes/traefik-openvpn.yaml")
  depends_on = [helm_release.traefik, helm_release.openvpn]
}