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

output "url" {
  value = "https://${var.domain}"
  description = "The website URL."
}
