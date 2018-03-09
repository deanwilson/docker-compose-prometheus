# AlertManager Server

Run a local alertmanager server and configure the prometheus container
to send alerts to it.

## Useful commands

View running config

    docker exec -ti promdocker_alert-manager_1 amtool --alertmanager.url http://127.0.0.1:9093 config

View active alerts

    docker exec -ti promdocker_alert-manager_1 amtool --alertmanager.url http://127.0.0.1:9093 alert

    Alertname  Starts At                Summary
    RedisDown  2018-03-04 22:23:25 UTC  Redis Availability alert.

