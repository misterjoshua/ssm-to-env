FROM debian:stable-slim

RUN apt-get update \
        && apt-get install -y \
            curl \
            jq \
            unzip \
        && rm -rf /var/lib/apt/lists/*

# Install AWS2
WORKDIR /tmp
RUN curl -LO "https://d1vvhvl2y92vvt.cloudfront.net/awscli-exe-linux-x86_64.zip" \
        && unzip awscli-exe-linux-x86_64.zip \
        && ./aws/install \
        && rm -rf ./aws \
        && aws2 --version

WORKDIR /
ADD ssm-to-env.sh /
ADD entrypoint.sh /

ENV SSM_PATH="/"
ENV ENV_FILE="/data/.env"

ENTRYPOINT [ "/entrypoint.sh" ]
