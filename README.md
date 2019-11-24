[![Build Status](https://travis-ci.org/misterjoshua/ssm-to-env.svg?branch=master)](https://travis-ci.org/misterjoshua/ssm-to-env)

# SSM to .ENV Container

This container image reads configuration settings from AWS SSM Parameter Store and writes them to a `.env` file on the filesystem. This sidecar container helps in these ways:

* Reads all parameter keys recursively from a given SSM Parameter Store path prefix.
* Applications don't need to know how to read SSM parameters.
* Task Definitions don't need to have dozens of `valueFrom` SSM environment variables per container.

This container is intended to be used in an `initContainer` in EKS or as a sidecar container task in Amazon ECS.

## Example Output

```
DATABASE_HOST = yourhostname.yourdomain
S3_BUCKET = foo.s3.amazonaws.com
S3_PREFIX = bar/baz
```

## Configuration

Configuration is done through environment variables.

| Environment Variable | Description |
| -------------------- | ----------- |
| `SSM_PATH` | The SSM Parameter Store path to recursively fetch configuration from. (Default: `/`)
| `ENV_FILE` | The location to write the `.env` file to. (Default: `/data/.env`)
| `AWS_DEFAULT_REGION` | The AWS CLI's default region.

## ECS Configuration

The container image will check for an ECS environment and automatically configure itself to use the ECS task role for querying the SSM Parameter store.

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
    "image": "wheatstalk/ssm-to-env:0.2",
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

* Ensure that your task is running with a task role that has permission to access the SSM parameters you wish to convert to `.env`.
