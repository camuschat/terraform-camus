# Terraform Camus

Deploy a [Camus][camus] server on DigitalOcean using Terraform.

This Terraform module creates a fully-configured Camus deployment on
DigitalOcean. It creates a DigitalOcean droplet, configures networking and
firewall rules, creates a DNS record for the desired domain, obtains an SSL
certificate via Let's Encrypt, and installs Camus, Coturn, and Nginx on the
droplet.

## Quickstart

### Prerequisites

1. You have a [DigitalOcean][digitalocean] account.
2. You have a domain (or subdomain) for your Camus instance.
3. You've [configured your domain registrar][configure-registrar] to use DigitalOcean's domain servers for your domain.
4. You have the [Terraform CLI][install-terraform] installed.

### Setup

Clone this repo:

```
$ git clone https://github.com/mrgnr/terraform-camus.git
```

Initialize Terraform modules & plugins:

```
$ cd terraform-camus && terraform init
```

### Configuration

Inside the cloned repo, create a file called `my-vars.tfvars`. This file will
contain your settings for the deployment. There are four variables that you
must set: `do_token`, `domain`, `certificate_email`, and `ssh_key_fingerprint`.
See the [module inputs](#inputs) documentation below for a list of all
variables.

An example `my-vars.tfvars` would be:

```
# Required
do_token = "1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef"
domain = "camus.example.com"
certificate_email = "admin@example.com"
ssh_key_fingerprint = "00:11:22:33:44:55:66:77:88:99:aa:bb:cc:dd:ee:ff"

# Optional
region = "tor1"
droplet_monitoring = true
```

### Deployment

Create a plan by running Terraform from the project root:

```
$ terraform plan -var-file my-vars.tfvars -out plan
```

Once you've checked the plan to make sure that it doesn't contain any
unintentional changes, apply the plan to create your deployment:

```
$ terraform apply plan
```

If the previous command ran successfully, you should have a Camus instance
running within a few minutes. (Note that it may take several hours for DNS
records to propagate.)

## Module documentation

### Inputs

| Name                | Description                                                                  | Type     | Default                                            | Required |
| ------------------- | ---------------------------------------------------------------------------- | -------- | -------------------------------------------------- | -------- |
| do_token            | Your Digital Ocean [API token][do-token].                                    | `string` |                                                    | Yes      |
| domain              | The domain for your site.                                                    | `string` |                                                    | Yes      |
| certificate_email   | The email address for the SSL certificate.                                   | `string` |                                                    | Yes      |
| ssh_key_fingerprint | The fingerprint of the [SSH key][do-add-ssh-key] to add to the droplet.      | `string` |                                                    | Yes      |
| region              | The region where the droplet is deployed.                                    | `string` | `"fra1"`                                           | No       |
| droplet_size        | The size of the droplet.                                                     | `string` | `"s-1vcpu-1gb"`                                    | No       |
| droplet_image       | The OS image for the droplet.                                                | `string` | `"ubuntu-20-04-x64"`                               | No       |
| droplet_backups     | Whether to enable backups on the droplet.                                    | `bool`   | `false`                                            | No       |
| droplet_monitoring  | Whether to enable monitoring on the droplet.                                 | `bool`   | `false`                                            | No       |
| droplet_ipv6        | Whether to enable IPv6 on the droplet.                                       | `bool`   | `false`                                            | No       |
| project_environment | The deployment environment for the project.                                  | `string` | `"Production"`                                     | No       |
| acme_url            | The URL of the ACME server used to obtain an SSL certificate.                | `string` | `"https://acme-v02.api.letsencrypt.org/directory"` | No       |
| coturn_enabled      | Whether to install and configure a Coturn TURN server on the droplet.        | `bool`   | `true`                                             | No       |
| coturn_listen_port  | The port to listen on for establishing new TURN connections.                 | `number` | `3478`                                             | No       |
| coturn_min_port     | The beginning of the port range to use for TURN connections.                 | `number` | `10000`                                            | No       |
| coturn_max_port     | The end of the port range to use for TURN connections.                       | `number` | `20000`                                            | No       |
| stun_host           | The hostname or IP address of the STUN server to use for connecting clients. | `string` | `""`                                               | No       |
| stun_port           | The port of the STUN server to use for connecting clients.                   | `number` | `19302`                                            | No       |
| twilio_account_sid  | A Twilio account SID.                                                        | `string` | `""`                                               | No       |
| twilio_auth_token   | A Twilio account [auth token][twilio-auth-token] or API key secret.          | `string` | `""`                                               | No       |
| twilio_key_sid      | A Twilio API key SID.                                                        | `string` | `""`                                               | No       |

### Outputs

| Name                 | Description                               |
| -------------------- | ----------------------------------------- |
| droplet_name         | The name of the Droplet.                  |
| droplet_id           | The ID of the Droplet.                    |
| droplet_urn          | The uniform resource name of the Droplet. |
| droplet_ipv4_address | The IPv4 address of the Droplet.          |
| droplet_ipv6_address | The IPv6 address of the Droplet.          |
| url                  | The website URL.                          |

### Example

You can call this module from other Terraform code, e.g.:

```
module "camus" {
  source = "github.com/mrgnr/terraform-camus"

  do_token = "1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef"
  domain = "camus.example.com"
  certificate_email = "admin@example.com"
  ssh_key_fingerprint = "00:11:22:33:44:55:66:77:88:99:aa:bb:cc:dd:ee:ff"
  region = "sgp1"
  droplet_size = "s-1vcpu-2gb"
  droplet_image = "debian-10-x64"
}
```

### Notes

The following droplet images are supported:

- `debian-10-x64`
- `ubuntu-20-04-x64`
- `ubuntu-18-04-x64`
- `centos-8-x64`
- `centos-7-x64`

[camus]: https://github.com/mrgnr/camus
[digitalocean]: https://www.digitalocean.com/
[install-terraform]: https://learn.hashicorp.com/tutorials/terraform/install-cli
[configure-registrar]: https://www.digitalocean.com/community/tutorials/how-to-point-to-digitalocean-nameservers-from-common-domain-registrars
[do-token]: https://www.digitalocean.com/docs/apis-clis/api/create-personal-access-token/
[do-add-ssh-key]: https://www.digitalocean.com/docs/droplets/how-to/add-ssh-keys/to-account/
[twilio-auth-token]: https://support.twilio.com/hc/en-us/articles/223136027-Auth-Tokens-and-How-to-Change-Them
