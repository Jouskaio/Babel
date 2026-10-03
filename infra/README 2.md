# Infrastructure

The API runs on its own VM, separate from the media server. The Flutter app is never deployed
here: it ships as store builds, a web build and desktop builds.

## First-time setup on the API VM

```bash
sudo mkdir -p /opt/babel && cd /opt/babel
# copy docker-compose.yml and create .env from api/.env.example
docker login ghcr.io          # read access to the private image
docker compose up -d
```

## Continuous deployment

Pushing an `api-vX.Y.Z` tag runs `.github/workflows/api-release.yml`, which publishes the image
to GHCR and runs `docker compose pull && up -d` over SSH.

Required secrets in the GitHub `production` environment:

| Secret | Value |
| --- | --- |
| `DEPLOY_HOST` | IP or hostname of the API VM |
| `DEPLOY_USER` | SSH user allowed to run Docker |
| `DEPLOY_SSH_KEY` | Private key of a deploy-only SSH key |
