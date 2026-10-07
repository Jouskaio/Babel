# Infrastructure

The API and the web build of the app run on their own server (Proxmox LXC container `babel`,
192.168.1.106), separate from the media server. Store builds (Android, iOS) are not deployed here.

| Service | Image | Port | Public URL |
| --- | --- | --- | --- |
| `api` | `ghcr.io/jouskaio/babel-api` | 8000 | `https://babel.jouskaio.me/api` |
| `web` | `ghcr.io/jouskaio/babel-web` | 8090 | `https://babel.jouskaio.me` |
| `db` | `postgres:17-alpine` | internal | — |
| files | NAS `Babel` share | `/srv/babel-files` | via `/api/v1/files/…` |

```
git tag api-vX.Y.Z / app-vX.Y.Z ─► GitHub Actions
                        1. build + push image to GHCR
                        2. join the tailnet as an ephemeral tag:ci node
                        3. Tailscale SSH as deploy@babel-api ─► docker compose pull && up -d <service>
                        4. smoke test GET /v1/health (api) or /healthz (web)
```

No SSH port is opened to the Internet and no SSH key is stored in GitHub: access is granted by
the Tailscale policy in [`tailscale-policy.hujson`](tailscale-policy.hujson).

## Public access (Nginx Proxy Manager)

Proxy host `babel.jouskaio.me` → `http://192.168.1.106:8090` (web app), with Let's Encrypt,
*Force SSL*, *Block Common Exploits* and *Websockets Support*. The API is published under `/api`
through the host's *Advanced* configuration:

```nginx
location /api/ {
    proxy_pass http://192.168.1.106:8000/;
    proxy_http_version 1.1;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header X-Forwarded-Prefix /api;
}
```

The proxy strips the prefix; `BABEL_ROOT_PATH=/api` in `/opt/babel/.env` keeps the OpenAPI
document and `/api/docs` consistent. Create the host without SSL first, check it over HTTP, then
request the certificate: Let's Encrypt validation needs the plain-HTTP host to work.

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
- `.env` holds the API settings (`BABEL_*`, see [`api/.env.example`](../api/.env.example)) and
  three secrets generated on the server, never stored anywhere else:

```bash
cd /opt/babel
echo "BABEL_JWT_SECRET=$(openssl rand -hex 32)" >> .env
echo "BABEL_DB_PASSWORD=$(openssl rand -hex 24)" >> .env
# Encrypts source access tokens: keep it, or every stored token must be entered again.
echo "BABEL_SECRETS_KEY=$(openssl rand -base64 32 | tr '+/' '-_')" >> .env
```

PostgreSQL (`db` service) has no published port and keeps its data in the `db-data` volume.

### Push notifications (optional)

New chapters of followed works are pushed through Firebase Cloud Messaging once the server
has a Firebase service account (Firebase console → Project settings → Service accounts →
Generate new private key). Copy the JSON to the server, readable by the API container only:

```bash
mkdir -p /opt/babel/secrets && chmod 700 /opt/babel/secrets
# copy the downloaded key to /opt/babel/secrets/firebase.json (mode 600, uid 10001)
echo "BABEL_FCM_CREDENTIALS_FILE=/run/babel-secrets/firebase.json" >> /opt/babel/.env
docker compose up -d api
```

Without it, notifications are only logged.

### Book files (NAS)

Book files live on the Synology shared folder `Babel` (`/volume1/Babel`, own quota and
snapshots, no recycle bin). The container is unprivileged and cannot mount NFS itself, so the
Proxmox host mounts it and passes it to the container:

```bash
# Proxmox host — the NFS rule on the NAS allows the host (192.168.1.183), maps all users to admin
echo "192.168.1.19:/volume1/Babel /mnt/babel nfs defaults,_netdev,hard,vers=3 0 0" >> /etc/fstab
mount /mnt/babel
pct set 107 -mp0 /mnt/babel,mp=/srv/babel-files && pct reboot 107
```

The `api` service mounts `/srv/babel-files` at `/data/files`. Administrators are listed in
`.env` (`BABEL_ADMIN_EMAILS=["you@example.com"]`).
The API applies pending migrations each time it starts.
- Tailscale joined with the server tag and Tailscale SSH:

```bash
tailscale up --hostname babel-api --advertise-tags tag:babel-api --ssh
```

### Tailscale admin console

1. **Access controls**: merge [`tailscale-policy.hujson`](tailscale-policy.hujson).
2. **Settings → Trust credentials**: create an OAuth client with the *Auth Keys (write)* scope
   and the `tag:ci` tag only.

### GitHub container registry

The deploy job logs the server into GHCR with the short-lived workflow token, pulls the image
and logs out again, so the package can stay private and no credential is kept on the server.

### GitHub (Settings → Environments → `production`)

| Secret | Value |
| --- | --- |
| `TS_OAUTH_CLIENT_ID` | OAuth client ID |
| `TS_OAUTH_SECRET` | OAuth client secret |

## Fuller book descriptions (Google Books)

Open Library often has one line, or nothing, for a book. Babel completes it from Google Books,
by ISBN and per language. Without a key the shared anonymous quota is usually used up; a free
key makes it reliable:

1. Google Cloud console, create a project, enable the **Books API**, then Credentials, create an
   **API key** (restrict it to the Books API).
2. On the server:

```bash
echo "BABEL_GOOGLE_BOOKS_API_KEY=<the key>" >> /opt/babel/.env
cd /opt/babel && docker compose up -d api
```

## Book requests (Chaptarr)

Premium readers can ask for a book that is in none of their sources. Babel asks Chaptarr (a
Readarr-family manager on the media server) to find it as an ebook; Chaptarr writes it into the
library folder Kavita reads, and Babel asks Kavita to scan once the file is there. Chaptarr
needs an ebook root folder, an ebook quality profile and an ebook metadata profile, and at least
one indexer and download client. Without the two settings below, requests are off.

```bash
# Chaptarr: Settings > General > API Key
echo "BABEL_CHAPTARR_URL=http://192.168.1.104:8789" >> /opt/babel/.env
echo "BABEL_CHAPTARR_API_KEY=<the key>" >> /opt/babel/.env
cd /opt/babel && docker compose up -d api
```

## Hardcover (saga volumes)

Hardcover names the volumes of a saga that the catalog lacks, so the saga page shows their titles
instead of an empty "missing" row. Public book data only, kept for a day (free key: 5000
requests a day). Hardcover's API is in beta and may change. Without the key, nothing changes.

```bash
# hardcover.app > Settings > Hardcover API > New API Key (read access is enough)
echo "BABEL_HARDCOVER_API_KEY=<the key>" >> /opt/babel/.env
cd /opt/babel && docker compose up -d api
```

