# INTRODUCION
This demo projects shows how to setup a basic monitoring scenario based on [Prometheus](https://prometheus.io/) and [Grafana](https://grafana.com/).
The idea is to monitor the health of web applications, in this case a [Apache Web Server](https://httpd.apache.org/) in its most basic configuration.
We also show how to monitor an exemplary [Hello World REST Service](https://hub.docker.com/r/vad1mo/hello-world-rest/). 
Both web applications mentioned are supposed to run via [Docker](https://hub.docker.com/) on the same EC2 instance, 
whereas [Prometheus](https://prometheus.io/) and [Grafana](https://grafana.com/) are installed and configured on another EC2.

# ARCHITECTURE

tbd image

# Prepare compute ressources

Install Node Exporter
  node exporter install.sh
  node-exporter.service /etc/systemd/system/
  node exporter setup.sh  
  Port 9100

# Prepare web application setup
1. Docker
2. Apache Server
3. REST Service
4. Autostart 

# Setup and configure monitoring stack 
1. Prometheus
2. Blackbox Exporter
3. Grafana

# REFERENCES

* [How to create an EC2 instance from AWS Console](https://www.techtarget.com/searchcloudcomputing/tutorial/How-to-create-an-EC2-instance-from-AWS-Console)
* [Running an Apache web server using Docker on EC2](https://www.imrankhan.dev/pages/apache-docker-ec2.html)
* [Hello World REST Service](https://hub.docker.com/r/vad1mo/hello-world-rest/)
* [DOCKER-CONTAINER AUTOMATISCH STARTEN](https://kofler.info/docker-container-automatisch-starten/)
* [Install Prometheus on AWS EC2](https://codewizardly.com/prometheus-on-aws-ec2-part1/)
* [Prometheus Node Exporter on AWS EC2](https://codewizardly.com/prometheus-on-aws-ec2-part2/)
* [Install Blackbox Exporter to Monitor Websites With Prometheus](https://blog.ruanbekker.com/blog/2019/05/17/install-blackbox-exporter-to-monitor-websites-with-prometheus/)
* [Installing Grafana on AWS EC2](https://medium.com/all-things-devops/how-to-install-grafana-on-aws-ec2-cefc01d5ff08)
* [Node Exporter Full](https://grafana.com/grafana/dashboards/1860-node-exporter-full)
* [Node Exporter for Prometheus Dashboard](https://grafana.com/grafana/dashboards/11074-node-exporter-for-prometheus-dashboard-en-v20201010/)
* [Prometheus Blackbox Exporter](https://grafana.com/grafana/dashboards/7587-prometheus-blackbox-exporter/)
