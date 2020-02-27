FROM alpine:3.11.3 AS fetch-assets

RUN apk add --no-cache git \
    wget \
    ca-certificates

ARG DIST_COMMIT=4d5728e7a4452d31030336c8e3ad9a006e58af18

WORKDIR /src/dist
RUN git clone https://github.com/caddyserver/dist .
RUN git checkout $DIST_COMMIT

RUN cp config/Caddyfile /Caddyfile
RUN cp welcome/index.html /index.html

WORKDIR /src

ARG CADDY_SOURCE_VERSION=v1.0.4
ARG CADDY_FILE_VERSION=v1.0.4
ARG CADDY_ARCH=arm64
RUN wget https://github.com/caddyserver/caddy/releases/download/${CADDY_SOURCE_VERSION}/caddy_${CADDY_FILE_VERSION}_linux_${CADDY_ARCH}.tar.gz
RUN tar xvf caddy_${CADDY_FILE_VERSION}_linux_${CADDY_ARCH}.tar.gz


FROM alpine:3.11.3 AS alpine
RUN apk add --no-cache bash

COPY --from=fetch-assets /src/caddy /usr/bin/caddy
COPY --from=fetch-assets /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs

COPY --from=fetch-assets /Caddyfile /etc/caddy/Caddyfile
COPY --from=fetch-assets /index.html /usr/share/caddy/index.html

ARG VCS_REF
ARG VERSION

EXPOSE 80
EXPOSE 443

CMD ["caddy", "-agree=true", "-log=stdout", "--conf=/etc/caddy/Caddyfile"]
