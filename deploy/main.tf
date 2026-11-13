# Adopts Uptime Kuma into OpenTofu through modules/app of SubZeroDev.Infra: a Cloudflare tunnel and the
# `uptime` DNS record, and a Portainer Git stack for the compose files in this repository. The image is a
# third-party one, so no GitHub deploy settings are created. Run through deploy/tofu.ps1; see deploy/README.md.
terraform {
  required_version = ">= 1.10"

  required_providers {
    cloudflare = { source = "cloudflare/cloudflare", version = "5.28.1" }
    portainer  = { source = "portainer/portainer", version = "2.2.0" }
    github     = { source = "integrations/github", version = "6.13.0" }
    random     = { source = "hashicorp/random", version = "3.9.1" }
    http       = { source = "hashicorp/http", version = "3.6.3" }
  }

  # Bucket, key and endpoint come from backend.hcl (Git-ignored); R2 keys from AWS_ACCESS_KEY_ID and
  # AWS_SECRET_ACCESS_KEY, which tofu.ps1 maps from the R2_* variables.
  backend "s3" {
    region                      = "auto"
    use_lockfile                = true
    use_path_style              = true
    skip_credentials_validation = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    skip_metadata_api_check     = true
    skip_s3_checksum            = true
  }

  encryption {
    key_provider "pbkdf2" "main" {
      passphrase = var.state_passphrase
    }
    method "aes_gcm" "main" {
      keys = key_provider.pbkdf2.main
    }
    state {
      method   = method.aes_gcm.main
      enforced = true
    }
    plan {
      method   = method.aes_gcm.main
      enforced = true
    }
  }
}

provider "cloudflare" {} # CLOUDFLARE_API_TOKEN

provider "github" {
  owner = "The-Running-Dev" # GITHUB_TOKEN
}

provider "portainer" {
  endpoint = var.portainer_url
  api_key  = var.portainer_api_key
  custom_headers = {
    "CF-Access-Client-Id"     = var.cf_access_client_id
    "CF-Access-Client-Secret" = var.cf_access_client_secret
  }
}

module "app" {
  source = "git::https://github.com/The-Running-Dev/SubZeroDev.Infra.git//modules/app?ref=v2.1.0"

  name          = "uptime" # The compose project of the running container; the stack takes it over
  repository    = "The-Running-Dev/SubZeroDev.Uptime"
  compose_files = ["docker-compose.yml", "compose.tunnel.yaml"]

  routes = { uptime = "http://uptime:3001" } # uptime.subzerodev.com

  # No image: Uptime Kuma is pinned in docker-compose.yml, not deployed through Infra.
  portainer_url = var.portainer_url
  portainer_credentials = {
    api_key              = var.portainer_api_key
    access_client_id     = var.cf_access_client_id
    access_client_secret = var.cf_access_client_secret
  }
  git_credentials = null # the repository is public
}

# uptime already exists as a proxied CNAME to the apex; it is repointed to the tunnel. The stack is new:
# Portainer has none for uptime (it ran from /srv/uptime), and Compose recreates the container in place.
import {
  to = module.app.cloudflare_dns_record.route["uptime"]
  id = "e958380ca90211dfa0fc68c5c2df277f/ba44d135d53314c2d3f24c4c33055b53"
}

output "public_url" {
  value = "https://uptime.subzerodev.com"
}
