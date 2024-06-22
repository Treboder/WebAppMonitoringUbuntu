# 1. INTRODUCION
This project demonstrates a basic monitoring scenario based on [Prometheus](https://prometheus.io/) and [Grafana](https://grafana.com/).
The idea is to demonstrate a basic system setup for the health monitoring of typical web applications.
For this purpose we use a [Apache Web Server](https://httpd.apache.org/) in its most basic configuration.
We also show how to monitor an exemplary [Hello World REST Service](https://hub.docker.com/r/vad1mo/hello-world-rest/). 
Both web applications mentioned are supposed to run via [Docker](https://hub.docker.com/) on the same EC2 instance, 
whereas [Prometheus](https://prometheus.io/) and [Grafana](https://grafana.com/) are installed and configured on another EC2.
Later we extend the monitoring stack with [Grafana Loki](https://grafana.com/oss/loki/) in order to trace logs.
The experimental setup described here contains two AWS EC2 instances of type t2.micro with Amazon-Linux, associated to AWS' Elastic IPs.

# 2. QUICKSTART
The project provides shell scripts installing and configuring a demo web server and a monitoring server. 
There are two scripts that manage the entire installation/configuration routine, one for the demo web server two apps and the second sets up the monitoring server with Prometheus and Grafana. 
After performing all the steps described here, all services should be up and running.
The only thing to be done manually is to adjust the IPs to your own IPs ;-)

## 3. PREREQUISITES

### YUM vs. DNF
For Strato-Server runnning on Ubuntu, replace yum with dnf  
````console
sudo apt install dnf
````
and replace the scripts accordingly, otherwise continue with yum.

### GIT
Install Git and clone the repository on both server. 
````console
sudo yum update -y
sudo yum install git -y
git version
git clone https://github.com/Treboder/WebAppMonitoringUbuntu
````

### Zip
For Strato-Server runnning on Ubuntu, install zip
````console
sudo apt install zip
````

## 4. SETUP WEB APPLICATION SERVER
SSH into your web app server and run the [setup_web_app_server.sh](setup_web_app_server.sh) script with:
````console
bash ./setup_web_app_server.sh
````
The script installs the node exporter and two demo web services:
* node exporter (:9100), 
* httpd web server (:8080), and 
* hello-world-rest-service (:5050)

The services should be running and we can check their status by calling their corresponding endpoints with:
````console
curl localhost:9100 
curl localhost:8080
curl localhost:5050
````
Given that your AWS EC2 security group has properly configured inbound rules, we should be able to access the endpoints from "outside" with:
* Node Exporter -> http://your_web_server_ip::9100 
* Apache -> http://your_web_server_ip::80
* REST -> http://your_web_server_ip::5050 

## 5. SETUP MONITORING SERVER
After SSH-ing into your monitoring machine, the very first step is to set the IP of your web app server. 
The repo already contains the [prometheus.yml](prometheus.yml) where Prometheus is configured, and IPs need to match your EC2 instances.
Then simply run the [setup_monitoring_server.sh](setup_monitoring_server.sh) script with:
````console
bash ./setup_monitoring_server.sh
````
The script should have installed:
* Node Exporter (:9100)
* Black Exporter (:9115)
* Prometheus (:9090)
* Grafana -> (:3000)
* Loki -> (:3100)
* Promtail

All services should be running and show active status, what can be checked with:
````console
systemctl status node_Exporter
systemctl status blackbox_exporter
systemctl status prometheus
systemctl status grafana-server
systemctl status loki
systemctl status promtail
````

All services should be running and respond via following endpoints, what can be checked with:
````console
curl localhost:9100 
curl localhost:9115
curl localhost:9090
curl localhost:3000
curl localhost:3100/metrics
curl localhost:9080
````
Given that your AWS EC2 security group has properly configured inbound rules, we should be able to access the following endpoints from "outside":
* Node Exporter -> http://your_monitoring_server_ip:9100
* Black Exporter -> http://your_monitoring_server_ip:9115
* Prometheus -> http://your_monitoring_server_ip:9090
* Grafana -> http://your_monitoring_server_ip:3000
* Loki -> http://your_monitoring_server_ip:3100
* Promtail -> http://your_monitoring_server_ip:9080

## 5.1. Update config.files

Monitoring Server  -> Edit the prometheus config */etc/prometheus/prometheus.yml*
Application Server -> Edit the Promtail config /usr/local/bin/config-promtail.yml

loki_config.yml
blackbox.yml

## 5.2 Grafana Setup
Most of the work is done, since all services are up and running.
Grafana Dashboards are exposed to port :3000
First Grafana-Login with admin:admin followed by request to create new password.
After login, go to "Configuration" and connect Grafana with Prometheus and Loki as datasources.
Then import some standard dashboards, which can be easily done via Grafana GUI.

As a quickstart to import the following dashboards with their IDs:
* 11074, 11133, or 1860 visualizing node exporter metrics
* 7587 visualizing blackbox exporter metrics
* 13186 Loki Dashboard

It's all set and you are free to play around with your web app monitoring stack.

# 6. ARCHITECTURE

tbd image

# 4. REFERENCES

  * [How to create an EC2 instance from AWS Console](https://www.techtarget.com/searchcloudcomputing/tutorial/How-to-create-an-EC2-instance-from-AWS-Console)
  * [How To Install Git In AWS EC2 Instance](https://cloudaffaire.com/how-to-install-git-in-aws-ec2-instance/)
  * [Running an Apache web server using Docker on EC2](https://www.imrankhan.dev/pages/apache-docker-ec2.html)
  * [Hello World REST Service](https://hub.docker.com/r/vad1mo/hello-world-rest/)
  * [DOCKER-CONTAINER AUTOMATISCH STARTEN](https://kofler.info/docker-container-automatisch-starten/)
  * [Install Prometheus on AWS EC2](https://codewizardly.com/prometheus-on-aws-ec2-part1/)
  * [Prometheus Node Exporter on AWS EC2](https://codewizardly.com/prometheus-on-aws-ec2-part2/)
  * [Install Blackbox Exporter to Monitor Websites With Prometheus](https://blog.ruanbekker.com/blog/2019/05/17/install-blackbox-exporter-to-monitor-websites-with-prometheus/)
  * [Installing Grafana on AWS EC2](https://medium.com/all-things-devops/how-to-install-grafana-on-aws-ec2-cefc01d5ff08)
  *[Install Grafana from APT repository](https://grafana.com/docs/grafana/latest/setup-grafana/installation/debian/)
  * [Node Exporter Full](https://grafana.com/grafana/dashboards/1860-node-exporter-full)
  * [Node Exporter for Prometheus Dashboard](https://grafana.com/grafana/dashboards/11074-node-exporter-for-prometheus-dashboard-en-v20201010/)
  * [Prometheus Blackbox Exporter](https://grafana.com/grafana/dashboards/7587-prometheus-blackbox-exporter/)
  * [Install and run Grafana Loki locally](https://grafana.com/docs/loki/latest/installation/local/)
  * [Install Loki Binary and Start as a Service](https://sbcode.net/grafana/install-loki-service/)
  * [Install Promtail Binary and Start as a Service](https://sbcode.net/grafana/install-promtail-service/)