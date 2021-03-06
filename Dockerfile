FROM ubuntu:focal AS fetcher

ARG channel=GA

# Setup apt for noninteractive mode
ENV DEBIAN_FRONTEND=noninteractive

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN apt-get update \
 && apt-get install -y --no-install-recommends curl gnupg2 jq ca-certificates \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* \
 && package=$(curl -fsSL https://install.enclave.io/manifest/linux.json | jq -r 'last(.ReleaseVersions[] | select(.ReleaseType == "'$channel'") | .Packages[].Url)') \
 && cd /tmp \
 && curl -fsSL "${package}" | tar xz

FROM ubuntu:focal

# Dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    libicu66 \
    libssl1.1 \
    zlib1g \
    libc6 \
    openssl \
    ca-certificates \
    iproute2 \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Helpers
# RUN apt-get install net-tools nano iputils-ping

RUN update-ca-certificates

WORKDIR /usr/bin
COPY --from=fetcher /tmp/enclave .
RUN chmod +x /usr/bin/enclave

ENTRYPOINT [ "enclave" ]
CMD [ "run" ]
