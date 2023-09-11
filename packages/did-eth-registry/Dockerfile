FROM debian:stable-slim as python-builder

# python3.10 is required for node-gyp

RUN export DEBIAN_FRONTEND=noninteractive && \
    apt update && \
    apt install -y -q --no-install-recommends \
    npm build-essential curl \
    ca-certificates apt-transport-https \
    libncursesw5-dev libssl-dev \
    libsqlite3-dev tk-dev libgdbm-dev \
    libc6-dev libbz2-dev libffi-dev zlib1g-dev \
    python3-pip python3-dev && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /build
ADD https://www.python.org/ftp/python/3.10.13/Python-3.10.13.tgz Python-3.10.13.tgz
RUN tar -xvf Python-3.10.13.tgz
WORKDIR /build/Python-3.10.13
RUN ./configure --enable-optimizations
RUN make -j4

FROM ghcr.io/xmtp/foundry:latest

RUN useradd --create-home -s /bin/bash did
RUN usermod -a -G sudo did
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Python 3.10

COPY --from=python-builder /build /build
WORKDIR /build/Python-3.10.13
RUN make install
RUN which python3 && python3 --version
RUN rm -rf /build

RUN mkdir -p /usr/local/nvm
ENV NVM_DIR=/usr/local/nvm

ENV NODE_VERSION=v14.21.3

ADD https://raw.githubusercontent.com/creationix/nvm/master/install.sh /usr/local/etc/nvm/install.sh
RUN bash /usr/local/etc/nvm/install.sh && \
    bash -c ". $NVM_DIR/nvm.sh && nvm install $NODE_VERSION && nvm alias default $NODE_VERSION && nvm use default"

ENV NVM_NODE_PATH ${NVM_DIR}/versions/node/${NODE_VERSION}
ENV NODE_PATH ${NVM_NODE_PATH}/lib/node_modules
ENV PATH      ${NVM_NODE_PATH}/bin:$PATH

RUN npm install npm@7.24.2 -g
RUN npm install yarn -g

ARG PROJECT=did-eth
WORKDIR /workspaces/${PROJECT}

RUN chown -R did:did /workspaces
COPY --chown=did:did . .

# build and test
RUN yarn install --frozen-lockfile
RUN yarn prettier:check
RUN yarn lint
RUN yarn build
RUN yarn test

USER did
