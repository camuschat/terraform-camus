terraform {
  required_providers {
    random = {
      source = "hashicorp/random"
      version = "3.0.0"
    }
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "2.2.0"
    }
    acme = {
      source = "vancluever/acme"
      version = "1.6.3"
    }
  }
}

locals {
  distro = split("-", var.droplet_image)[0]
}

resource "random_password" "coturn_static_auth_secret" {
  length = 32
}

provider "digitalocean" {
  token = var.do_token
}

resource "digitalocean_project" "main" {
  name = "camus"
  description = "Camus video chat server"
  purpose = "Web Application"
  environment = var.project_environment
  resources = [
    digitalocean_droplet.main.urn,
    digitalocean_domain.main.urn
  ]
}

resource "digitalocean_droplet" "main" {
  image = var.droplet_image
  name = "camus"
  region = var.region
  size = var.droplet_size
  ssh_keys = [var.ssh_key_fingerprint]
  backups = var.droplet_backups
  monitoring = var.droplet_monitoring
  ipv6 = var.droplet_ipv6
  vpc_uuid = digitalocean_vpc.main.id

  # Provision the droplet using cloud-config
  user_data = join("\n", [
    templatefile("${path.module}/cloud-config/common.yaml", {
      # Nginx configuration
      nginx_conf = templatefile("${path.module}/nginx.conf", { domain = var.domain })

      # SSL certificiates
      ssl_cert = "${acme_certificate.certificate.certificate_pem}${acme_certificate.certificate.issuer_pem}"
      ssl_key = acme_certificate.certificate.private_key_pem

      # Coturn configuration
      turn_conf = var.coturn_enabled ? templatefile("${path.module}/turnserver.conf", {
        realm = "turn.${var.domain}"
        listen_port = var.coturn_listen_port
        min_port = var.coturn_min_port
        max_port = var.coturn_max_port
        static_auth_secret = random_password.coturn_static_auth_secret.result
      }) : ""
    }),
    templatefile("${path.module}/cloud-config/${local.distro}.yaml", {
      coturn_enabled = var.coturn_enabled

      # Settings passed to Camus
      stun_host = var.stun_host
      stun_port = var.stun_port
      turn_host = var.coturn_enabled ? "turn.${var.domain}" : ""
      turn_port = var.coturn_enabled ? var.coturn_listen_port : ""
      turn_static_auth_secret = var.coturn_enabled ? "\"${random_password.coturn_static_auth_secret.result}\"" : ""
      twilio_account_sid = var.twilio_account_sid
      twilio_auth_token = var.twilio_auth_token
      twilio_key_sid = var.twilio_key_sid
    })
  ])

  tags = ["camus"]
}

resource "digitalocean_vpc" "main" {
  name = "camus"
  region = var.region
}

resource "digitalocean_firewall" "main" {
  name = "camus"

  droplet_ids = [digitalocean_droplet.main.id]

  inbound_rule {
    protocol = "icmp"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol = "tcp"
    port_range = "22"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol = "tcp"
    port_range = "80"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol = "tcp"
    port_range = "443"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  dynamic "inbound_rule" {
    for_each = var.coturn_enabled ? [1] : []
    content {
      protocol = "tcp"
      port_range = var.coturn_listen_port
      source_addresses = ["0.0.0.0/0", "::/0"]
    }
  }

  dynamic "inbound_rule" {
    for_each = var.coturn_enabled ? [1] : []
    content {
      protocol = "udp"
      port_range = "${var.coturn_min_port}-${var.coturn_max_port}"
      source_addresses = ["0.0.0.0/0", "::/0"]
    }
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "udp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}

resource "digitalocean_domain" "main" {
  name = var.domain
}

resource "digitalocean_record" "main" {
  domain = digitalocean_domain.main.name
  type = "A"
  name = "@"
  value = digitalocean_droplet.main.ipv4_address
}

resource "digitalocean_record" "turn" {
  domain = digitalocean_domain.main.name
  type = "CNAME"
  name = "turn"
  value = "${var.domain}."
}

resource "digitalocean_record" "stun" {
  domain = digitalocean_domain.main.name
  type = "CNAME"
  name = "stun"
  value = "${var.domain}."
}

provider "acme" {
  server_url = var.acme_url
}

resource "tls_private_key" "private_key" {
  algorithm = "RSA"
}

resource "acme_registration" "reg" {
  account_key_pem = tls_private_key.private_key.private_key_pem
  email_address = var.certificate_email
}

resource "acme_certificate" "certificate" {
  account_key_pem = acme_registration.reg.account_key_pem
  common_name = digitalocean_domain.main.id
  subject_alternative_names = [digitalocean_record.turn.fqdn, digitalocean_record.stun.fqdn]
  key_type = "4096"

  dns_challenge {
    provider = "digitalocean"
    config = {
      DO_AUTH_TOKEN = var.do_token
    }
  }
}
