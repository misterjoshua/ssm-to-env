FROM python:alpine

ARG CLI_VERSION=1.16.86

RUN apk -uv add --no-cache bash curl groff jq less && \
    pip install --no-cache-dir awscli==$CLI_VERSION

ADD ssm-to-env.sh /

ENV AWS_ACCESS_KEY_ID=""
ENV AWS_SECRET_ACCESS_KEY=""
ENV AWS_DEFAULT_REGION=""
ENV SSM_PATH="/"
ENV ENV_FILE=""
ENV AWS_PROFILE=""

ENTRYPOINT [ "/ssm-to-env.sh" ]