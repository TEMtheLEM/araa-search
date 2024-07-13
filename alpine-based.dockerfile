FROM python:alpine

# LABEL can be used to attach metadata to the container.
LABEL title="Araa Search" \
      description="A privacy-respecting, ad-free, self-hosted Google metasearch engine with strong security and full API support." \
      git_repo="https://github.com/TEMtheLEM/araa-search" \
      authors="https://github.com/Extravi/araa-search/contributors" \
      maintainer="TEMtheLEM <temthelem@duck.com>" \
      image="https://hub.docker.com/r/temthelem/araa-search"

WORKDIR /app

COPY requirements.txt /app/

RUN apk add --update --no-cache --virtual .build_deps libxml2-dev libxslt-dev gcc libc-dev

# We will only be running our own python app in a container,
# so this shouldn't be terrible.
RUN pip3 install --break-system-packages -r requirements.txt

RUN apk del .build_deps

ENV ORIGIN_REPO=https://github.com/TEMtheLEM/araa-search

COPY . .

CMD [ "sh", "scripts/docker-cmd.sh" ]
