# docker-compose-prometheus

A set of Docker Compose configs to run a local Prometheus test environment.

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

We now need to configure Grafana to use Prometheus as its data source. Login
to the dashboard, click the icon on the top left and click "Data sources". You
can then point it to your Prometheus container.

![Add Prometheus Data source](/add-prometheus-datasource.png?raw=true "Add Prometheus Data source")

Once you've done this click on the `Dashboards` tab and import each of the
dashboards. You can then view the
[Prometheus graphs](http://127.0.0.1:3000/dashboard/db/prometheus-stats).

Congratulations! You now have a prometheus and grafana test instance and you can
experiment with making your own scrape backed graphs. You'll soon want to expand
into data from other services, and an ideal place to start is with
[Redis](./redis-server/README.md).

### Networking

All the containers are created inside a single docker network and reference each
other by the magic of their service names. They can also be reached from the
host on `127.0.0.1`. This allows easier access to the prometheus and grafana
dashboards and means you can easily add sample data to the graphs by running
command such as `redis-cli` in a loop or pointing a load tester at them.
