## Redis monitoring and metrics

In this document we will add Redis, and the Redis exporter that presents
information to prometheus, to our test stack and then import a Grafana
dashboard to show us the real time results.

### Warning

Before going any further in this document please ensure you've read
the [main README](/README.md) which explains the requirements
and steps you'll need to do before adding redis will succeed.

### Running redis

In this directory is a [redis docker-compose](/redis-server/docker-compose.yaml)
config file. This will run a redis server and a prometheus exporter that will
connect to it. The [redis target config](redis-server/redis.json) is then
added to the prometheus configs, which is enough to enable prometheus to start
scraping and collecting the metrics.

To spin the containers up run

    docker-compose -f prometheus-server/docker-compose.yaml -f redis-server/docker-compose.yaml up -d

You can confirm that the containers are running with

    docker-compose -f prometheus-server/docker-compose.yaml -f redis-server/docker-compose.yaml ps

and view any output:

    docker-compose -f prometheus-server/docker-compose.yaml -f redis-server/docker-compose.yaml logs

Now everything is running you can view the exporter, and its status,
on the [Prometheus Targets](http://127.0.0.1:9090/targets) page. You
can confirm data is being loaded by querying the
[redis_instance_info metric](http://127.0.0.1:9090/graph?g0.range_input=1h&g0.expr=redis_instance_info&g0.tab=1)

Now we have all the pieces configured and running we'll add a third party
[Grafana dashboard](https://grafana.com/dashboards?dataSource=prometheus)
to our instance to help us visualise the results. This part of the
process is currently very manual but hopefully this will become more automated
over time.

 * Click on the "Home" button on the top left of the Grafana dashboard
 * Click "Import Dashboard" (on the right of the dashboard list)
 * Add the dashboard ID, [763](https://grafana.com/dashboards/763) in this case,
   and click else where in the dialog box.

You will then be presented with the "Import Dashboard" dialog box

![Import dashboard](/images/import-redis-dashboard.png?raw=true "Import redis dashboard")

Select your prometheus data source, which we created in the main README earlier
and named "Prometheus". This will import and enable the dashboard. You can now
click over to the
[Prometheus Redis Dashboard](http://127.0.0.1:3000/dashboard/db/prometheus-redis)
and view its details.

![Redis dashboard](/images/redis-dashboard.png?raw=true "Sample redis dashboard")

### Access the redis container

The redis container is assigned its default port on the host loopback
interface so you can use tools like `redis-cli` to connect directly to it.
This allows you to execute commands you can then view on the dashboards or use
load testing tools to generate additional traffic.

    $ redis-cli ping

By default we require password auth to successfully connect. The default password
can be found in the [redis docker-compose file](/redis-server/docker-compose.yaml)
in the `command` section.
