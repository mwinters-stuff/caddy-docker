FROM golang:1.13.6-alpine as builder

WORKDIR /src

RUN apk add --no-cache \
    wget \
    ca-certificates

ARG CADDY_SOURCE_VERSION=v1.0.4
# -b $CADDY_SOURCE_VERSION
RUN wget https://github.com/caddyserver/caddy/releases/download/v1.0.4/caddy_v1.0.4_linux_arm64.tar.gz

RUN tar xvf caddy_v1.0.4_linux_arm64.tar.gz
# WORKDIR /src/
# RUN CGO_ENABLED=0 GOOS=linux GOARCH=arm64 \
#     go build -trimpath -tags netgo -ldflags '-extldflags "-static" -s -w' -o /usr/bin/caddy

# Fetch the latest default welcome page and default Caddy config
FROM alpine:3.11.3 AS fetch-assets

RUN apk add --no-cache git

ARG DIST_COMMIT=4d5728e7a4452d31030336c8e3ad9a006e58af18

WORKDIR /src/dist
RUN git clone https://github.com/caddyserver/dist .
RUN git checkout $DIST_COMMIT

RUN cp config/Caddyfile /Caddyfile
RUN cp welcome/index.html /index.html

FROM alpine:3.11.3 AS alpine
RUN apk add --no-cache bash

COPY --from=builder /src/caddy /usr/bin/caddy
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs

COPY --from=fetch-assets /Caddyfile /etc/caddy/Caddyfile
COPY --from=fetch-assets /index.html /usr/share/caddy/index.html

ARG VCS_REF
ARG VERSION

EXPOSE 80
EXPOSE 443

CMD ["caddy", "-agree=true", "-log=stdout", "--conf=/etc/caddy/Caddyfile"]

# FROM scratch AS scratch

# COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs
# COPY --from=builder /usr/bin/caddy /usr/bin/caddy

# COPY --from=fetch-assets /Caddyfile /etc/caddy/Caddyfile
# COPY --from=fetch-assets /index.html /usr/share/caddy/index.html

# ARG VCS_REF
# ARG VERSION
# LABEL org.opencontainers.image.revision=$VCS_REF
# LABEL org.opencontainers.image.version=$VERSION
# LABEL org.opencontainers.image.title=Caddy
# LABEL org.opencontainers.image.description="a powerful, enterprise-ready, open source web server with automatic HTTPS written in Go"
# LABEL org.opencontainers.image.url=https://caddyserver.com
# LABEL org.opencontainers.image.documentation=https://github.com/caddyserver/caddy/wiki/v2:-Documentation
# LABEL org.opencontainers.image.vendor="Light Code Labs"
# LABEL org.opencontainers.image.licenses=Apache-2.0
# LABEL org.opencontainers.image.source="https://github.com/caddyserver/caddy-docker"

# EXPOSE 80
# EXPOSE 443
# EXPOSE 2019

# ENTRYPOINT ["caddy"]
# CMD ["run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile"]
