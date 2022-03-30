# syntax=docker/dockerfile:1.3

FROM node:16.14.2-bullseye

USER node:node
WORKDIR /home/node

RUN git clone --branch v4.6.3 --depth=1 --quiet https://github.com/microsoft/TypeScript.git
RUN --mount=type=cache,target=/home/node/.npm,uid=1000,gid=1000 cd /home/node/TypeScript && npm ci
RUN rm -rf /home/node/TypeScript/.git

FROM node:16.14.2-bullseye-slim

# There is an issue on GitHub Actions so we can not use mount=type=cache
RUN apt-get update \
    && apt-get install -y --no-install-recommends awscli \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/

USER node:node
WORKDIR /home/node

COPY --from=0 --chown=node:node /home/node/TypeScript ./TypeScript

COPY bench.sh /bench.sh

ENTRYPOINT [ "/bench.sh" ]
