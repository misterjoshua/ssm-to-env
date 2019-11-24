#!/bin/bash -e

SSM_PATH=${SSM_PATH:-/}

aws2 ssm get-parameters-by-path --path "$SSM_PATH" --recursive \
    | jq '.Parameters[] | (.Name | sub(".*/"; "")) + " = " + .Value | @text' --raw-output
