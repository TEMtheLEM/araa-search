FROM python:3.12.4-alpine AS builder

# Container metadata.
LABEL title="Araa Search" \
      description="A privacy-respecting, ad-free, self-hosted Google metasearch engine with strong security and full API support." \
      git_repo="https://github.com/TEMtheLEM/araa-search" \
      authors="https://github.com/Extravi/araa-search/contributors" \
      maintainer="TEMtheLEM <temthelem@duck.com>" \
      image="https://hub.docker.com/r/temthelem/araa-search"

WORKDIR /build

# Packages needed to build lxml on 32-bit platforms
RUN apk add --update --no-cache --virtual .build_deps \
        pkgconf \
        zlib-dev \
        xz \
        xz-dev \
        libxml2 \
        libxml2-utils \
        libxml2-dev \
        libgpg-error \
        libgcrypt \
        libxslt \
        libxslt-dev \
        libgcc \
        jansson \
        libstdc++ \
        zstd-libs \
        binutils \
        libgomp \
        libatomic \
        gmp \
        isl26 \
        mpfr4 \
        mpc1 \
        gcc \
        musl-dev

COPY requirements.txt .

# We will only be running our own python app in a container,
# so this shouldn't be terrible.
RUN pip3 install --break-system-packages -r requirements.txt

# Stash build, take only what's needed.
FROM python:3.12.4-alpine AS deployment

ARG TARGETARCH

# Both of these packages are needed for lxml to work on 32-bit platforms.
# Package installation can be skipped on 64-bit platforms.
RUN if ! [[ $TARGETARCH = *64* ]]; then \
        apk add --update --no-cache \
        libxml2 \
        libxslt; \
    fi

COPY --from=builder /usr/local/lib/python3.12/site-packages /usr/local/lib/python3.12/site-packages
COPY --from=builder /usr/local/bin/gunicorn /usr/local/bin/gunicorn

WORKDIR /app

COPY . .

ENV ORIGIN_REPO=https://github.com/TEMtheLEM/araa-search

CMD [ "sh", "scripts/docker-cmd.sh" ]
