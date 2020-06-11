# docker-compose-prometheus

A set of Docker Compose configs to run a local Prometheus test environment

### Table of contents

 * [Introduction](/README.md#introduction)
 * [Getting started](/README.md#getting-started)
   - [Existing services](/README.md#existing-services)
 * [Architecture and layout](/README.md#architecture-and-layout)
   - [Networking](/README.md#networking)
 * [Extending](/README.md#extending)

## Introduction

This repository contains the configuration required to create local
[Prometheus](https://prometheus.io/) and [Grafana](https://grafana.com/)
containers and link them together so you can experiment with metric
collection and graphing.

Although it makes it possible to bootstrap a very simple, 2 container
infrastructure the most useful additions are the configs in the other
directories. Each of these will add a service and exporter that link
in to the base prometheus and allow you to experiment and learn
how to monitor and graph other services. A good place to start is
with the the Prometheus and Redis combination documented below.

## Getting started

The only things you need to run these examples are `docker-compose` and a copy
of this repo. Everything else happens inside the docker containers.

A note about the hideous command lines. In order to make this a modular experiment
I've extracted the separate sections of config in to different directories.
While this allows you to spin up a test site with any combination of services
and exporters it does mean you'll need to add a `-f $foo/docker-compose.yaml`
argument for each service you want to include in the test. I avoid the pain by
setting an alias:

    alias dc='docker-compose -f prometheus-server/docker-compose.yaml -f redis-server/docker-compose.yaml'

And then use commands like `dc up -d` and `dc logs`. In the README examples I'll
use the full commands for clarity but you won't have to.

### Creating Prometheus

The first part of the infrastructure you should build, and the one depended on by
all the example service configurations in other directories, is
[prometheus-server](./prometheus-server/docker-compose.yaml). This will create
both a prometheus and grafana container. At the moment we'll have to manually
link these together.

From the root of this repo run the command to create the docker containers.

    docker-compose -f prometheus-server/docker-compose.yaml up -d

On the first run this might take a little while as it fetches all the
containers. Once it returns you can confirm the containers are running:

    docker-compose -f prometheus-server/docker-compose.yaml ps

```
> docker-compose -f prometheus-server/docker-compose.yaml ps
            Name                           Command             State   Ports
-----------------------------------------------------------------------------------------
prometheusserver_grafana_1      /run.sh                        Up  0.0.0.0:3000->3000/tcp
prometheusserver_prometheus_1   /bin/prometheus --config.f ... Up  0.0.0.0:9090->9090/tcp

```

and view their output:

    docker-compose -f prometheus-server/docker-compose.yaml logs

When you're finished you can remove the containers, but don't do that yet.

    docker-compose -f prometheus-server/docker-compose.yaml down

Once the containers have been created you can view the
[Prometheus dashboard](http://127.0.0.1:9090/graph) and the
[Grafana Dashboard](http://127.0.0.1:3000/) (login with admin / secret).

Now Grafana 5 has been released we can move to configuring the Prometheus data
source with a [datasource.yaml](/prometheus-server/config/datasource.yaml) file
and remove the manual steps. You should still click through to
the [import dashboard page](http://127.0.0.1:3000/datasources/edit/1/dashboards)
screen and import each of those available. You can then view the
[Prometheus graphs](http://127.0.0.1:3000/dashboard/db/prometheus-stats).

Congratulations! You now have a prometheus and grafana test instance and you can
experiment with making your own scrape backed graphs. You'll soon want to expand
into data from other services, and an ideal place to start is with
[Redis](./redis-server/README.md).

### Existing Services

This repo currently contains example configurations for the following
services and their respective exporters:

 * [Memcached](/memcached-server)
 * [Node exporter](/node-exporter) - just an exporter running against your local
   host
 * [PostgreSQL](/postgresql-server)
 * [Prometheus and Grafana](/prometheus-server)
 * [Redis Server](/redis-server)

### Networking

All the containers are created inside a single docker network and reference each
other by the magic of their service names. They can also be reached from the
host on `127.0.0.1`. This allows easier access to the prometheus and grafana
dashboards and means you can easily add sample data to the graphs by running
command such as `redis-cli` in a loop or pointing a load tester at them.

## Architecture and layout

One of the key goals in this experiment is to keep it as modular as possible
and allow you to create container networks of whichever combination you need.
Does your application use PostgreSQL and redis? Add a new `docker-
compose.yaml` for your application itself and just include `redis-server/docker-
compose.yaml` and `postgresql-server/docker-compose.yaml` on the
command line to create those backing services and collect metrics on them all.

To implement this we have a subdirectory for each different thing we
want to collect metrics for. This contains the prometheus target
configuration file, mostly in `${subdirectory_name}.json` and a `docker-
compose.yaml` file that defines how to run the service inside a
container. Critically, the compose file contains
an additional `prometheus` service definition.

```
  prometheus:
    volumes:
      - ${PWD}/redis-server/redis.json:/etc/prometheus/targets/redis.json
```

Docker compose has a wonderful feature that ensures additional values for a
service, even one defined in a separate docker-compose file, are
merged to create a configuration that contains all encountered keys. In
the case of this repo it means we can define the basic prometheus checks
in the base `docker-compose.yaml` file and add the additional checks as we
include the services they target.

## Extending

Adding a new data source or your own application should be a simple process.

 * create a new subdirectory
 * add a `docker-compose.yaml` file that can run your container
 * ensure the `prometheus:` volume line points to your own service
 * add the prometheus target config in the service specific `json` file
 * run `docker-compose up` with all the services you want specified using
   multiple `-f $foo/docker-compose.yaml` arguments
 * add a README detailing your work

## Debugging

To extract the complete base prometheus config file so you can check
its contents after it is concatenated.

    docker cp prometheus-server_config-concat_1:/fragments/complete/prometheus.yml /tmp/prometheus.yml

### Author ###

[Dean Wilson](http://www.unixdaemon.net)
