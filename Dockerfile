# syntax=docker/dockerfile:1
ARG GO_VERSION=1.26
FROM golang:${GO_VERSION}-bookworm AS build

ARG BRIDGE_VERSION=v3.27.1
RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential pkg-config git libsecret-1-dev libfido2-dev libcbor-dev \
    && rm -rf /var/lib/apt/lists/*

RUN git clone --depth 1 --branch "${BRIDGE_VERSION}" https://github.com/ProtonMail/proton-bridge.git /src
WORKDIR /src
RUN make build-nogui

FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates gnupg pass socat libsecret-1-0 libfido2-1 libcbor0.8 \
    && rm -rf /var/lib/apt/lists/* \
    && useradd --create-home --home-dir /data --uid 1000 bridge

COPY --from=build /src/bridge /usr/local/bin/bridge
COPY scripts/entrypoint.sh /usr/local/bin/entrypoint.sh

USER bridge
ENV HOME=/data
VOLUME /data
# Exposed (socat-forwarded) ports: IMAP 143, SMTP 25
EXPOSE 143 25

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["run"]
