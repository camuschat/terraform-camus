terraform {
  required_providers {
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

provider "digitalocean" {
  token = var.do_token
}

resource "digitalocean_project" "main" {
  name = "camus"
  description = "Camus video chat server"
  purpose = "Web Application"
  environment = "Production"
  resources = [
    digitalocean_droplet.main.urn,
    digitalocean_domain.main.urn
  ]
}

resource "digitalocean_droplet" "main" {
  image = "ubuntu-20-04-x64"
  name = "camus"
  region = var.region
  size = var.droplet_size
  ssh_keys = [var.ssh_key_fingerprint]
  backups = var.droplet_backups
  monitoring = var.droplet_monitoring
  ipv6 = var.droplet_ipv6
  vpc_uuid = digitalocean_vpc.main.id
  user_data = templatefile("${path.module}/provision.yaml", {
    nginx_conf = templatefile("${path.module}/nginx.conf", { domain = var.domain })
    ssl_cert = "${acme_certificate.certificate.certificate_pem}${acme_certificate.certificate.issuer_pem}",
    ssl_key = acme_certificate.certificate.private_key_pem
  })
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

provider "acme" {
  server_url = "https://acme-v02.api.letsencrypt.org/directory"
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
  common_name = var.domain
  key_type = "4096"

  dns_challenge {
    provider = "digitalocean"
    config = {
      DO_AUTH_TOKEN = var.do_token
    }
  }
}
