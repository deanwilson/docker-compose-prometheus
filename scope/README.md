## Weave Scope

"_[Weave Scope is a visualisation and monitoring tool for Docker and Kubernetes.](https://www.weave.works/oss/scope/)_"

![Weave Scope Dashboard](/images/scope-dashboard.png?raw=true "Weave Scope Dashboard")

As I've added more services and exporters to the 
[Docker Compose Prometheus project](https://github.com/deanwilson/docker-compose-prometheus)
the number of possible different arrangements and configurations has
exploded and I decided it was time to find a more visual way to describe
exactly what was running. Weave Scopes ability to automatically generate
a map of the services and show some connectivity details between the containers
made it the perfect tool for an initial experiment. 

To run Scope add an additional `docker-compose.yaml` to your command line:

```
docker-compose \
  -f prometheus-server/docker-compose.yaml \
  -f alertmanager-server/docker-compose.yaml \
  -f node-exporter/docker-compose.yaml \
  -f mailhog-server/docker-compose.yaml \
  -f pushgateway/docker-compose.yaml 
  -f redis-server/docker-compose.yaml
  -f scope/docker-compose.yaml \
  up -d
```

and then view the [scope dashboard](http://localhost:4040/) on your local machine.
