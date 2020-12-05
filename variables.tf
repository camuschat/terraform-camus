variable "do_token" {
  type = string
  description = "Your Digital Ocean API token."
  sensitive = true
}

variable "domain" {
  type = string
  description = "The domain for your site."
}

variable "certificate_email" {
  type = string
  description = "The email address for the SSL certificate."
}

variable "ssh_key_fingerprint" {
  type = string
  description = "The fingerprint of the SSH key to add to the droplet."
}

variable "region" {
  type = string
  default = "fra1"
  description = "The region where the droplet is deployed."
}

variable "droplet_size" {
  type = string
  default = "s-1vcpu-1gb"
  description = "The size of the droplet."
}

variable "droplet_backups" {
  type = bool
  default = false
  description = "Whether to enable backups on the droplet."
}

variable "droplet_monitoring" {
  type = bool
  default = false
  description = "Whether to enable monitoring on the droplet."
}

variable "droplet_ipv6" {
  type = bool
  default = false
  description = "Whether to enable IPv6 on the droplet."
}
