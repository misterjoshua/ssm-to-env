#!/bin/bash -e

AWS_PROFILE=${AWS_PROFILE:-default}

if [ ! -z "$AWS_CONTAINER_CREDENTIALS_RELATIVE_URI" ]; then
    # Set up a cli config that gets credentials from the EcsContainer.
    mkdir -p ~/.aws

    cat >~/.aws/config <<END
[profile ecs]
region = ca-central-1
END
    cat >~/.aws/credentials <<END
[ecs]
credential_source = EcsContainer
END

    AWS_PROFILE=ecs
fi

# Test that we can access the caller identity.
aws sts get-caller-identity --profile $AWS_PROFILE >/dev/null

# Invoke the ssm to env script.
AWS_PROFILE=$AWS_PROFILE \
./ssm-to-env.sh
