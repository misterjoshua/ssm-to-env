[![Build Status](https://travis-ci.org/misterjoshua/ssm-to-env.svg?branch=master)](https://travis-ci.org/misterjoshua/ssm-to-env)

# SSM to .ENV Container

This container image reads properties from the AWS SSM Parameter Store and converts them to a `.env` file format so that apps don't need to know how to read SSM Parameters to be configured through SSM. This container is intended to be used in an `initContainer` in EKS or as sidecar container task in Amazon ECS that your main container depends on completing first.

The container image will check for an ECS environment and automatically configure itself to use the ECS task role for querying the SSM Parameter store.

## Configuration

Configuration is done through environment variables.

| Environment Variable | Description |
| -------------------- | ----------- |
| `SSM_PATH` | The SSM Parameter Store path to recursively fetch configuration from. (Default: `/`)
| `ENV_FILE` | The location to write the `.env` file to. (Default: `/data/.env`)
| `AWS_DEFAULT_REGION` | The AWS CLI's default region.

## ECS Configuration

To use this container in an ECS task:

* Add a shared volume named `env` to your task's volumes at the end of `.volumes[]`:
```
{
    "name": "env",
    "dockerVolumeConfiguration": {
        "driver": "local",
        "scope": "task"
    }
}
```
* Add the `env` volume to your main container by adding this snippet it at the end of `.containerDefinitions[0].mountPoints[]`:

```
{
    "sourceVolume": "env",
    "containerPath": "/env",
    "readOnly": false
}
```

* Add this container to your task's container list at the end of `.containerDefinitions[]`:

```
{
    "name": "ssm-to-env",
    "image": "wheatstalk/ssm-to-env:latest",
    "memory": 256,
    "essential": false,
    "portMappings": [],
    "environment": [
        {
            "name": "AWS_DEFAULT_REGION",
            "value": "your-region-1"
        },
        {
            "name": "SSM_PATH",
            "value": "/"
        },
        {
            "name": "ENV_FILE",
            "value": "/data/.env"
        }
    ],
    "mountPoints": [
        {
            "sourceVolume": "env",
            "containerPath": "/data",
            "readOnly": false
        }
    ]
}
```

* Set your main container depend on this sidecar to be `COMPLETE` before it can run at the end of `.containerDefinitions[0].dependsOn[]`:

```
{
    "containerName": "ssm-to-env",
    "condition": "COMPLETE"
}
```
