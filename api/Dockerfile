# syntax=docker/dockerfile:1

# ---------------------------------------------------------------- build
FROM ghcr.io/astral-sh/uv:python3.13-bookworm-slim AS build
ENV UV_COMPILE_BYTECODE=1 UV_LINK_MODE=copy UV_PYTHON_DOWNLOADS=never
WORKDIR /app

# Dependencies first: this layer stays cached while the lockfile is unchanged
COPY pyproject.toml uv.lock ./
RUN uv sync --frozen --no-dev --no-install-project

COPY README.md ./
COPY src ./src
RUN uv sync --frozen --no-dev

# ---------------------------------------------------------------- runtime
FROM python:3.13-slim-bookworm AS runtime
# bsdtar (libarchive) opens CBR comics, which are converted to CBZ for the readers.
RUN apt-get update \
 && apt-get install -y --no-install-recommends libarchive-tools \
 && rm -rf /var/lib/apt/lists/*
RUN useradd --system --uid 10001 --no-create-home babel
WORKDIR /app
COPY --from=build --chown=babel:babel /app /app
ENV PATH="/app/.venv/bin:$PATH" PYTHONUNBUFFERED=1
USER babel
EXPOSE 8000
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s \
  CMD python -c "import urllib.request,sys; sys.exit(0 if urllib.request.urlopen('http://127.0.0.1:8000/v1/health').status == 200 else 1)"
# Pending database migrations are applied before the server starts.
CMD ["sh", "-c", "python -m babel_api.scripts.migrate && exec uvicorn babel_api.main:app --host 0.0.0.0 --port 8000 --proxy-headers"]
