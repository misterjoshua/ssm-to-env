#!/bin/bash -e

SSM_PATH=${SSM_PATH:-/}
ENV_FILE=${ENV_PATH:-}
AWS_PROFILE=${AWS_PROFILE:-}

if [ ! -z "$AWS_PROFILE" ]; then
    AWS_PROFILE_ARG="--profile $AWS_PROFILE"
fi

ENV=$(aws ssm get-parameters-by-path --path "$SSM_PATH" $AWS_PROFILE_ARG \
    | jq '.Parameters[] | (.Name | sub(".*/"; "")) + " = " + .Value | @text' \
        --raw-output)

if [ ! -z "$ENV_FILE" ]; then
    cat <<<$ENV >$ENV_FILE
else
    cat <<<$ENV
fi