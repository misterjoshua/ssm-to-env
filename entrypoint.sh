#!/bin/bash -e

if [ ! -z "$AWS_CONTAINER_CREDENTIALS_RELATIVE_URI" ]; then
    # Detected an ECS environment. Set up a cli config that gets
    # credentials from the EcsContainer.
    mkdir -p ~/.aws

    cat >~/.aws/config <<END
[profile default]
region = ca-central-1
END
    cat >~/.aws/credentials <<END
[default]
credential_source = EcsContainer
END

fi

# Test that we can access the caller identity.
aws2 sts get-caller-identity >/dev/null

# Invoke the ssm to env script.
if [ -z "$ENV_FILE" ]; then
    ./ssm-to-env.sh
else
    echo "Writing environment variables from SSM parameter path $SSM_PATH to $ENV_FILE"
    mkdir -p $(dirname $ENV_FILE)
    ./ssm-to-env.sh >$ENV_FILE
fi
