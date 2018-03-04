# promconf-concat docker container

This directory contains all the files needed to build the prometheus
config file concatentor used by the
[docker-compose-prometheus](https://github.com/deanwilson/docker-compose-prometheus)
project to enable using different fragments of configuration.

## Introduction

Prometheus only allows you to specify a single configuration file
which must contain all the config, without any ability to use any kind
of include functionality. In my docker-compose-prometheus experiments
I want to be able to specify a number of discrete components, some of which
cannot be configured via `file_sd_configs` so instead I've built this container
image which will build a single config from a number of separate config file
fragments.

## How it works

The `promconf-concat` container mounts a docker volume under
`/fragments/` and runs a while loop that essentially combines all the file
fragments found in that directory and then writes them into a single, combined
prometheus config file. The actual implementation is written like this:

    cat /base_prometheus.yml /fragments/*.yml > /prometheus.yml

As this is using standard shell globbing to select the files you can add
ordering with careful selection of file names. This combined file is then
checked against the current `prometheus.yml` file and if they differ the
new one overwrites the old. Prometheus then detects this change and reloads its
config.

A concrete example of this is the
[alertmanager-server/docker-compose.yaml](/alertmanager-server/docker-compose.yaml)
config, which adds alertmanager configuration under the `alerting:` key.

To add another fragment to `promconf-concat` you should include config like this
in your `docker-compose.yaml` file.

```
  config-concat:
    volumes:
      - ${PWD}/alertmanager-server/config/prometheus-config.yml:/fragments/alertmanager-server.yml
```

This will then be combined with the other fragments into one config file, written to a location
under the volume and presented to the prometheus container. The prometheus
container also mounts this volume and then runs with the given config.

## Container build command

To build the container you'll need docker installed:

    docker build -t promconf-concat:0.1.0 .

## Push the container to dockerhub

I'm testing this on Fedora 26 which doesn't default to docker.io
as the remote registery so I'm being very specific in my commandlines.

    docker login docker.io

Tag the container. Use your own name here

    docker tag promconf-concat docker.io/deanwilson/promconf-concat:0.1.0

And then push to dockerhub

    docker push docker.io/deanwilson/promconf-concat:0.1.0
