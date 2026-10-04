# Serves the Flutter web build. The build itself runs in CI (`flutter build web`) and this
# image only packages `build/web` with a static, unprivileged nginx listening on 8080.
FROM nginxinc/nginx-unprivileged:1.29-alpine
COPY web.nginx.conf /etc/nginx/conf.d/default.conf
COPY build/web /usr/share/nginx/html
EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=3s CMD wget -qO- http://127.0.0.1:8080/healthz || exit 1
