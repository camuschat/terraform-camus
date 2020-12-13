output "droplet_name" {
  value = digitalocean_droplet.main.name
  description = "The name of the Droplet."
}

output "droplet_id" {
  value = digitalocean_droplet.main.id
  description = "The ID of the Droplet."
}

output "droplet_urn" {
  value = digitalocean_droplet.main.urn
  description = "The uniform resource name of the Droplet."
}

output "droplet_ipv4_address" {
  value = digitalocean_droplet.main.ipv4_address
  description = "The IPv4 address of the Droplet."
}

output "droplet_ipv6_address" {
  value = digitalocean_droplet.main.ipv6_address
  description = "The IPv6 address of the Droplet."
}

output "url" {
  value = "https://${var.domain}"
  description = "The website URL."
}
