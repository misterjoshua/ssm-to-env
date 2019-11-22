#!/bin/bash -e

SSM_PATH=${SSM_PATH:-/}
ENV_FILE=${ENV_FILE:-}
AWS_PROFILE=${AWS_PROFILE:-default}

PARAMS=$(aws ssm get-parameters-by-path --path "$SSM_PATH" --recursive --profile $AWS_PROFILE)
ENV=$(cat <<<$PARAMS \
    | jq '.Parameters[] | (.Name | sub(".*/"; "")) + " = " + .Value | @text' \
        --raw-output)

if [ ! -z "$ENV_FILE" ]; then
    cat <<<$ENV >$ENV_FILE
    echo "Wrote $ENV_FILE"
else
    cat <<<$ENV
fi
