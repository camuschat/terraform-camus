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

variable "droplet_image" {
  type = string
  default = "ubuntu-20-04-x64"
  description = "The OS image for the droplet."
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

variable "project_environment" {
  type = string
  default = "Production"
  description = "The deployment environment for the project."
}

variable "acme_url" {
  type = string
  default = "https://acme-v02.api.letsencrypt.org/directory"
  description = "The URL of the ACME server used to obtain an SSL certificate."
}

variable "coturn_enabled" {
  type = bool
  default = true
  description = "Whether to install and configure a Coturn TURN server on the droplet."
}

variable "coturn_listen_port" {
  type = number
  default = 3478
  description = "The port to listen on for establishing new TURN connections."
}

variable "coturn_min_port" {
  type = number
  default = 10000
  description = "The beginning of the port range to use for TURN connections."
}

variable "coturn_max_port" {
  type = number
  default = 20000
  description = "The end of the port range to use for TURN connections."
}

variable "database_url" {
  type = string
  default = ""
  description = "A URL identifying the database to be used. If not given, a local SQLite database is used."
}

variable "secret_key" {
  type = string
  default = ""
  sensitive = true
  description = "The secret key used by the Camus server for user sessions and cookie signing."
}

variable "stun_host" {
  type = string
  default = ""
  description = "The hostname or IP address of the STUN server to use for connecting clients."
}

variable "stun_port" {
  type = number
  default = 19302
  description = "The port of the STUN server to use for connecting clients."
}

variable "twilio_account_sid" {
  type = string
  default = ""
  description = "A Twilio account SID."
}

variable "twilio_auth_token" {
  type = string
  default = ""
  description = "A Twilio account auth token or API key secret."
}

variable "twilio_key_sid" {
  type = string
  default = ""
  description = "A Twilio API key SID."
}
