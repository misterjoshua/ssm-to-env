FROM python:alpine

ARG CLI_VERSION=1.16.289

RUN apk -uv add --no-cache bash curl groff jq less && \
    pip install --no-cache-dir awscli==$CLI_VERSION

ADD ssm-to-env.sh /
ADD entrypoint.sh /

ENV AWS_DEFAULT_REGION="ca-central-1"
ENV SSM_PATH="/"
ENV ENV_FILE="/data/.env"

ENTRYPOINT [ "/entrypoint.sh" ]
