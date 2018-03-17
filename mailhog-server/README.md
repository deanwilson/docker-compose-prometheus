# MailHog Server for AlertManager alerts

[MailHog](https://github.com/mailhog/MailHog) is a fake SMTP server
that receives emails and then displays them via its internal web server.
In this repository we use it as an AlertManager target so we can visually
see what the triggered alerts look like.

If you include MailHog via `docker-compose` it will add a basic AlertManager
config that matches every alert and then sends them to MailHog for processing.

![MailHog UI with alert](/images/alertmanager-to-mailhog.png?raw=true "MailHog displaying AlertManager alert")
