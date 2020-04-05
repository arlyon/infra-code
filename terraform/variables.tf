variable "traefik_version" {
  type        = string
  description = "Which version of the traefik chart to use."
  default     = "7.2.0"
}

variable "minio_version" {
  type        = string
  description = "Which version of the minio chart to use."
  default     = "5.0.11"
}

variable "external_dns_version" {
  type        = string
  description = "Which version of the external-dns chart to use."
  default     = "2.20.2"
}

variable "openvpn_version" {
  type        = string
  description = "Which version of the openvpn chart to use."
  default     = "4.2.0"
}

variable "polaris_version" {
  type        = string
  description = "Which version of the polaris chart to use."
  default     = "0.10.2"
}

variable "guacamole_version" {
  type        = string
  description = "Which version of the guacamole chart to use."
  default     = "0.2.0"
}

variable "jaeger_version" {
  type        = string
  description = "Which version of the jaeger-operator chart to use."
  default     = "2.13.1"
}

variable "elastic_version" {
  type        = string
  description = "Which version of the elastic chart to use."
  default     = "7.6.1"
}
