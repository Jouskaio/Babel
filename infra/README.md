# Infrastructure

The API runs on its own server (Proxmox LXC container `babel`), separate from the media server.
The Flutter app is never deployed here: it ships as store, web and desktop builds.

```
git tag api-vX.Y.Z ─► GitHub Actions
                        1. build + push image to GHCR (public)
                        2. join the tailnet as an ephemeral tag:ci node
                        3. Tailscale SSH as deploy@babel-api ─► docker compose pull && up -d
                        4. smoke test GET /v1/health
```

No port is opened to the Internet and no SSH key is stored in GitHub: access is granted by
the Tailscale policy in [`tailscale-policy.hujson`](tailscale-policy.hujson).

## Server setup (one time)

### Proxmox host (the container is unprivileged)

```bash
pct set 107 --features nesting=1,keyctl=1                  # Docker inside LXC
printf 'lxc.cgroup2.devices.allow: c 10:200 rwm\nlxc.mount.entry: /dev/net/tun dev/net/tun none bind,create=file\n' \
  >> /etc/pve/lxc/107.conf                                  # /dev/net/tun for Tailscale
pct reboot 107
```

### Inside the container

- Docker CE, Compose plugin and Tailscale from their official Debian repositories.
- Unprivileged `deploy` user, member of the `docker` group.
- `/opt/babel/` owned by `deploy`, containing `docker-compose.yml` and `.env` (mode 600).
- Tailscale joined with the server tag and Tailscale SSH:

```bash
tailscale up --hostname babel-api --advertise-tags tag:babel-api --ssh
```

### Tailscale admin console

1. **Access controls**: merge [`tailscale-policy.hujson`](tailscale-policy.hujson).
2. **Settings → OAuth clients**: create a client with the *Auth Keys (write)* scope and the
   `tag:ci` tag.

### GitHub container registry

The deploy job logs the server into GHCR with the short-lived workflow token, pulls the image
and logs out again, so the package can stay private and no credential is kept on the server.

### GitHub (Settings → Environments → `production`)

| Secret | Value |
| --- | --- |
| `TS_OAUTH_CLIENT_ID` | OAuth client ID |
| `TS_OAUTH_SECRET` | OAuth client secret |
