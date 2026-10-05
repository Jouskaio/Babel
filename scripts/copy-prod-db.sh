#!/usr/bin/env bash
# Copies the production database into a local PostgreSQL, to develop on real data
# without ever touching production.
#
#   ./scripts/copy-prod-db.sh            export from the server, restore locally
#
# Then start the API on the copy (from api/):
#   BABEL_DATABASE_URL=postgresql+asyncpg://babel:babel@localhost:5433/babel \
#     uv run uvicorn babel_api.main:app --reload
#
# Settings (environment variables):
#   BABEL_PROD_SSH        SSH target of the server       (default: deploy@babel-api)
#   BABEL_LOCAL_DB_PORT   port of the local PostgreSQL   (default: 5433)
#
# The copy holds real accounts (emails, password hashes): it stays on this machine.
# The dump is deleted right after the restore. Sources' access tokens cannot be read
# locally (they need the server's BABEL_SECRETS_KEY), and book files stay on the NAS.
set -euo pipefail

SSH_TARGET="${BABEL_PROD_SSH:-deploy@babel-api}"
PORT="${BABEL_LOCAL_DB_PORT:-5433}"
CONTAINER="babel-db-local"
IMAGE="postgres:17-alpine" # same major version as production

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
WORK="$ROOT/api/.local"
DUMP="$WORK/prod.dump"
mkdir -p "$WORK"
chmod 700 "$WORK"
trap 'rm -f "$DUMP"' EXIT

echo "1/3  Export from $SSH_TARGET…"
# pg_dump runs inside the production database container: no port is opened.
ssh "$SSH_TARGET" "docker exec babel-db pg_dump -U babel -d babel --format=custom" >"$DUMP"
echo "     $(du -h "$DUMP" | cut -f1) exported"

echo "2/3  Local PostgreSQL ($CONTAINER, port $PORT)…"
if ! docker ps -a --format '{{.Names}}' | grep -qx "$CONTAINER"; then
  docker run -d --name "$CONTAINER" \
    -e POSTGRES_USER=babel -e POSTGRES_PASSWORD=babel -e POSTGRES_DB=babel \
    -p "127.0.0.1:$PORT:5432" -v babel-db-local:/var/lib/postgresql/data \
    "$IMAGE" >/dev/null
fi
docker start "$CONTAINER" >/dev/null
for _ in $(seq 1 30); do
  docker exec "$CONTAINER" pg_isready -U babel -d postgres >/dev/null 2>&1 && break
  sleep 1
done

echo "3/3  Restore (the previous local copy is replaced)…"
docker exec "$CONTAINER" psql -q -U babel -d postgres \
  -c "DROP DATABASE IF EXISTS babel WITH (FORCE)" \
  -c "CREATE DATABASE babel OWNER babel" >/dev/null
docker exec -i "$CONTAINER" pg_restore -U babel -d babel --no-owner --no-privileges <"$DUMP"

USERS="$(docker exec "$CONTAINER" psql -tA -U babel -d babel -c 'SELECT count(*) FROM users')"
VERSION="$(docker exec "$CONTAINER" psql -tA -U babel -d babel -c 'SELECT version_num FROM alembic_version')"
cat <<DONE

Done: $USERS account(s), migration $VERSION.
Start the API on the copy (from api/):

  BABEL_DATABASE_URL=postgresql+asyncpg://babel:babel@localhost:$PORT/babel uv run uvicorn babel_api.main:app --reload

Migrations newer than production apply to the copy only:
  BABEL_DATABASE_URL=postgresql+asyncpg://babel:babel@localhost:$PORT/babel uv run python -m babel_api.scripts.migrate
DONE
