# Uptime Kuma monitors

This is the monitor layout configured in Kuma at `https://uptime.subzerodev.com` on 2026-11-18. Kuma stores monitors in its database, not in this repository. Use this file to rebuild the setup or check it for drift.

## Defaults

| Setting | Value |
|---|---|
| Notification | `Watchdog` (webhook, the Kuma default) on every monitor |
| Retries | 3 before alerting, retry every 60s |
| Interval | 60s for containers, VPS endpoints and TCP; 300s for static sites |
| TLS | certificate-expiry alerts on for every HTTP monitor |
| Docker host | `Local`, socket `/var/run/docker.sock` |

## Groups

A group goes down when any monitor in it goes down. Each app stack's group holds its containers and its public endpoint.

### Adventures

- Docker: `adventures-api`, `adventures-web`, `adventures-db`, `adventures-ledger-db`, `adventures-cloudflared-1`
- HTTP: `Adventures API - Web` → `https://adventures-api.subzerodev.com/healthz`

### BibleStudy

- Docker: `biblestudy-biblestudy-1`, `biblestudy-db-1`, `biblestudy-backup-1`, `biblestudy-cloudflared-1`
- HTTP: `BibleStudy - Web` → `https://biblestudy.subzerodev.com/__health`

### Dashboard

- Docker: `subzerodev-dashboard-api-1`, `subzerodev-dashboard-worker-1`, `subzerodev-dashboard-db-1`, `subzerodev-dashboard-backup-1`, `subzerodev-dashboard-cloudflared-1`
- HTTP keyword: `Dashboard - Web` → `https://dashboard.subzerodev.com/health/ready`, body must contain `ready`

### Gitea

- Docker: `gitea-gitea-1`, `gitea-db-1`, `gitea-runner-1`, `gitea-cloudflared-1`
- HTTP: `Gitea - Web` → `https://git.subzerodev.com/api/healthz`

### Blog bot

- Docker: `blog-bot`, `blog-bot-cloudflared-1`
- HTTP: `Blog bot - Web` → `https://blogging.subzerodev.com/health`

### SubZeroDev.com

- Docker: `subzerodev-com`, `subzerodev-web-cloudflared-1`
- HTTP: `SubZeroDev.com - Web` → `https://subzerodev.com/`; `SubZeroDev.com www - Web` → `https://www.subzerodev.com/`

### Platform

- Docker: `portainer` (named `Portainer`), `watchdog` (named `Watchdog`), `edge-cloudflared`, `uptime`, `uptime-cloudflared-1`, `watchdog-cloudflared-1`
- HTTP: `Portainer - Web` → `https://containers.subzerodev.com`; `Watchdog - Web` → `https://watchdog.subzerodev.com/health`

`uptime`, `watchdog` and `containers` sit behind Cloudflare Access, so an unauthenticated HTTP check proves little about the origin. Their Docker monitors are the real signal.

### Static sites - GitHub Pages (300s)

`https://<name>.subzerodev.com/` for `adventures`, `blog`, `build-agent`, `docs-template`, `game-engine`, `git-service`, `platform`, `plugins-github`, `portfolio`, `psgenerator`, `suntrap`, `wiki`, `winget`, `workspace`.

`wiki` and `git-service` return 404 and are **paused** until their path is fixed or they are retired.

### Static sites - ChatGPT (300s)

`https://<name>.subzerodev.com/` for `agentkit`, `hotcorners`, `ogrelife`, `projectair`.

### Host guard (TCP, `89.233.108.244`)

| Monitor | Port | Mode |
|---|---|---|
| `VPS port 22 open` | 22 | normal: must accept connections |
| `VPS port 80 closed` | 80 | upside down: alerts if anything listens |
| `VPS port 81 closed` | 81 | upside down |
| `VPS port 443 closed` | 443 | upside down |

## Not covered

Kuma runs on the VPS it monitors, so it cannot alert when the whole VPS is down. An external watcher (for example UptimeRobot on `uptime.subzerodev.com` and `subzerodev.com`) covers that and is set up outside this repository.

## When adding a stack

Add a group named after the stack, a Docker monitor per container, and an HTTP monitor on its public health path, then update this file.
