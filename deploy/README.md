# deploy

OpenTofu root that puts Uptime Kuma under SubZeroDev.Infra's `modules/app`: a Cloudflare tunnel with `uptime.subzerodev.com`, and a Portainer Git stack (`docker-compose.yml` + `compose.tunnel.yaml`). State: R2 bucket `subzerodev-tofu-state`, key `apps/uptime.tfstate`, encrypted. Run everything through `deploy/tofu.ps1`.

Uptime Kuma runs a third-party image pinned in `docker-compose.yml`, so there is no deploy job: change the pin in a PR and Portainer redeploys. Its data is the bind mount `/srv/uptime/data`, untouched by any of this.

## First adoption

1. Merge the PR that adds these files to `main`.
2. `./deploy/tofu.ps1 plan`. Expect: a tunnel, the `uptime` record repointed, and a new stack `uptime`.
3. Apply, check `https://uptime.subzerodev.com`, then a second `plan` shows no changes.
