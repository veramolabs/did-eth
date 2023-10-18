FROM ghcr.io/xmtp/foundry:latest

RUN useradd --create-home -s /bin/bash did
RUN usermod -a -G sudo did
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Python 
RUN export DEBIAN_FRONTEND=noninteractive && \
    apt update && \
    apt install -y -q --no-install-recommends \
    python3-pip python3-dev python3 && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

ARG PROJECT=did-eth
WORKDIR /workspaces/${PROJECT}

RUN chown -R did:did /workspaces
COPY --chown=did:did . .

# build and test
RUN yarn install --frozen-lockfile
RUN yarn prettier:check
RUN yarn lint
RUN forge test -v
RUN forge geiger --check contracts/*.sol
RUN forge coverage

USER did
