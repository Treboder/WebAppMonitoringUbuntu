# 1. INTRODUCION
This demo projects shows how to setup a basic monitoring scenario based on [Prometheus](https://prometheus.io/) and [Grafana](https://grafana.com/).
The idea is to demonstrate a basic system setup for the health monitoring of typical web applications.
For this purpose we use a [Apache Web Server](https://httpd.apache.org/) in its most basic configuration.
We also show how to monitor an exemplary [Hello World REST Service](https://hub.docker.com/r/vad1mo/hello-world-rest/). 
Both web applications mentioned are supposed to run via [Docker](https://hub.docker.com/) on the same EC2 instance, 
whereas [Prometheus](https://prometheus.io/) and [Grafana](https://grafana.com/) are installed and configured on another EC2.

The experimental setup described here contains two AWS EC2 instances of type t2.micro with Amazon-Linux.
We also use AWS' Elastic IPs with following IP adresses used in config files described later:
* 3.85.149.192 (Monitoring Stack Server)
* 52.202.41.59 (Web Application Server)

# 2. QUICKSTART

````
sudo yum update -y
sudo yum install git -y
git version
git clone https://github.com/Treboder/WebAppMonitoringEC2
````

## 2.1. SETUP WEB APPLICATION SERVER
	````
	bash ./setup_web_app_server.sh
	curl localhost:9100 
	curl localhost:8080
	curl localhost:5050
	````

## 2.2. SETUP MONITORING SERVER
	````
	bash ./setup_monitoring_server.sh
	curl localhost:9100 
	curl localhost:9115
	curl localhost:9090
	curl localhost:3000
	````

## 2.3. ENDPOINTS OVERVIEW

After performing all the steps described here, there will be following endpoints available. 
Please dont forget to adjust the IPs to your own IPs ;-)

## Monitoring Stack Server (3.85.149.192)
* Node Exporter -> http://3.85.149.192:9100
* Black Exporter -> http://3.85.149.192:9115
* Prometheus -> http://3.85.149.192:9090
* Alert Manager -> http://3.85.149.192:9093
* Grafana -> http://3.85.149.192:3000

## Web Application Server (52.202.41.59)
* Node Exporter -> http://52.202.41.59:9100 
* Apache -> http://52.202.41.59:80
* REST -> http://52.202.41.59:5050 

# 3. ARCHITECTURE

tbd image

# 4. SYSTEM SETUP PROCEDURE
The entire procedure is organized in 6 sequential steps:
* 4.1. PREPARE COMPUTE RESOURCES
* 4.2. SETUP WEB APPLICATIONS
* 4.3. INSTALL PROMETHEUS
* 4.4. INSTALL BLACKBOX EXPORTER AND CONFIGURE PROMETHEUS
* 4.5. INSTALL GRAFANA AND CONFIGURE DEMO DASHBOARDS 
* 4.6. SETUP DEMO ALERTING RULES

## 4.1. PREPARE COMPUTE RESOURCES
We assume that two linux-based machines are available, one for the web applications and one for the monitoring stack.
After provisioning the compute resources, we install [Prometheus Node Exporter](https://github.com/prometheus/node_exporter) on both instances.
As a result we should see the Node Exporter endpoint exposed to port 9100 (dont forget to open the port by adjusting the security group).
 1. Install Git in case you want to use the scripts and config files directly from this repo (https://github.com/Treboder/WebAppMonitoringEC2)
    ````
    sudo yum update -y
    sudo yum install git -y
    git version
    git clone https://github.com/Treboder/WebAppMonitoringEC2
    ````
 2. Create a user for Prometheus Node Exporter and install Node Exporter binaries 
    -> [scripts/node_exporter_install.sh](scripts/node_exporter_install.sh)
    ```
    sudo useradd --no-create-home node_exporter
    wget https://github.com/prometheus/node_exporter/releases/download/v1.0.1/node_exporter-1.0.1.linux-amd64.tar.gz
    tar xzf node_exporter-1.0.1.linux-amd64.tar.gz
    sudo cp node_exporter-1.0.1.linux-amd64/node_exporter /usr/local/bin/node_exporter
    rm -rf node_exporter-1.0.1.linux-amd64.tar.gz node_exporter-1.0.1.linux-amd64
    ```
 3. Create /etc/systemd/system/node-exporter.service if it doesn’t exist
    -> [configs/node_exporter.service](configs/node_exporter.service)
    ```
    [Unit]
    Description=Prometheus Node Exporter Service
    After=network.target

    [Service]
    User=node_exporter
    Group=node_exporter
    Type=simple
    ExecStart=/usr/local/bin/node_exporter

    [Install]
    WantedBy=multi-user.target
    ```
 4. Configure systemd and start the servcie
    -> [scripts/node_exporter_setup.sh](scripts/node_exporter_setup.sh)   
    ```
    sudo systemctl daemon-reload
    sudo systemctl enable node_exporter
    sudo systemctl start node_exporter
    sudo systemctl status node_exporter
    ```

## 4.2. SETUP WEB APPLICATIONS
We run both apps standalone via separate Docker container, without any dependencies between them.   
1. Install Docker and start as a service (on every reboot)
    ```
    sudo yum update -y
    sudo amazon-linux-extras install docker -y
    sudo systemctl daemon-reload
    sudo systemctl enable docker   
    sudo systemctl start docker   
    sudo systemctl status docker 
    ```
2. Run Apache Server (httpd) as docker -> check welcome message on port 80 
   ````
   sudo docker pull httpd
   sudo docker run -d -p 80:80 httpd
   curl localhost:80
   ````  
3. Run an exemplary REST Service as docker -> check endpoint on port 5050
   ````
   sudo docker pull vad1mo/hello-world-rest
   sudo docker run -d -p 5050:5050 vad1mo/hello-world-rest
   curl localhost:5050/foo/bar
   ````
4. Start web app services on every reboot automtically (--restart always)
   ````
   sudo docker run -p 5050:5050 --name hello-world-rest -d --restart always vad1mo/hello-world-rest
   sudo docker run -p 8080:80 --name apache -d --restart always httpd
   ````

## 4.3. INSTALL PROMETHEUS
   
   1. Create user and install Prometheus (download, extract and copy binaries before clean up)
   -> [scripts/prometheus_install.sh](scripts/prometheus_install.sh)
   ````   
   sudo useradd --no-create-home prometheus
   sudo mkdir /etc/prometheus
   sudo mkdir /var/lib/prometheus      
   wget https://github.com/prometheus/prometheus/releases/download/v2.19.0/prometheus-2.19.0.linux-amd64.tar.gz
   tar xvfz prometheus-2.19.0.linux-amd64.tar.gz
   sudo cp prometheus-2.19.0.linux-amd64/prometheus /usr/local/bin
   sudo cp prometheus-2.19.0.linux-amd64/promtool /usr/local/bin/
   sudo cp -r prometheus-2.19.0.linux-amd64/consoles /etc/prometheus
   sudo cp -r prometheus-2.19.0.linux-amd64/console_libraries /etc/prometheus
   sudo cp prometheus-2.19.0.linux-amd64/promtool /usr/local/bin/
   rm -rf prometheus-2.19.0.linux-amd64.tar.gz prometheus-2.19.0.linux-amd64   
   ````
   
   2. Configure Prometheus and specify node exporter endpoints as targets
   Create or replace the content of /etc/prometheus/prometheus.yml
   -> [configs/prometheus.yml](configs/prometheus.yml)
   ````
   global:
    scrape_interval: 15s
    external_labels:
     monitor: 'prometheus'

   scrape_configs:
    - job_name: 'prometheus'
      static_configs:
        - targets: ['localhost:9100']
        - targets: ['52.202.41.59:9100'] # dont forget to adjust with your IPs
   ````
   
   3. Prepare Prometheus to run as service and therefore create file /etc/systemd/system/prometheus.service
   -> [configs/prometheus.service](configs/prometheus.service)
   ````
   [Unit]
   Description=Prometheus
   Wants=network-online.target
   After=network-online.target

   [Service]
   User=prometheus
   Group=prometheus
   Type=simple
   ExecStart=/usr/local/bin/prometheus \
    --config.file /etc/prometheus/prometheus.yml \
    --storage.tsdb.path /var/lib/prometheus/ \
    --web.console.templates=/etc/prometheus/consoles \
    --web.console.libraries=/etc/prometheus/console_libraries

   [Install]
   WantedBy=multi-user.target
   ````
   
   4. Start Prometheus as a service after changing the permissions and configuring systemd 
   -> [scripts/prometheus_setup.sh](scripts/prometheus_setup.sh)
   ````
   sudo chown prometheus:prometheus /etc/prometheus
   sudo chown prometheus:prometheus /usr/local/bin/prometheus
   sudo chown prometheus:prometheus /usr/local/bin/promtool
   sudo chown -R prometheus:prometheus /etc/prometheus/consoles
   sudo chown -R prometheus:prometheus /etc/prometheus/console_libraries
   sudo chown -R prometheus:prometheus /var/lib/prometheus   
   sudo systemctl daemon-reload
   sudo systemctl enable prometheus   
   sudo systemctl start prometheus   
   sudo systemctl status prometheus      
   ````
   
## 4.4. INSTALL BLACKBOX EXPORTER AND CONFIGURE PROMETHEUS

   1. Create user, install binaries and prepare config file
   ````
   sudo useradd --no-create-home --shell /bin/false blackbox_exporter
   wget https://github.com/prometheus/blackbox_exporter/releases/download/v0.14.0/blackbox_exporter-0.14.0.linux-amd64.tar.gz
   tar -xvf blackbox_exporter-0.14.0.linux-amd64.tar.gz
   sudo cp blackbox_exporter-0.14.0.linux-amd64/blackbox_exporter /usr/local/bin/blackbox_exporter
   sudo chown blackbox_exporter:blackbox_exporter /usr/local/bin/blackbox_exporter
   rm -rf blackbox_exporter-0.14.0.linux-amd64*   
   sudo mkdir /etc/blackbox_exporter
   sudo touch /etc/blackbox_exporter/blackbox.yml
   sudo chown blackbox_exporter:blackbox_exporter /etc/blackbox_exporter/blackbox.yml
   ````
   3. Populate config file /etc/blackbox_exporter/blackbox.yml 
   ````
   modules:
    http_2xx:
     prober: http
     timeout: 5s
     http:
      valid_status_codes: []
      method: GET
   ````
   4. Create service file /etc/systemd/system/blackbox_exporter.service
   ````
   [Unit]
   Description=Blackbox Exporter
   Wants=network-online.target
   After=network-online.target

   [Service]
   User=blackbox_exporter
   Group=blackbox_exporter
   Type=simple
   ExecStart=/usr/local/bin/blackbox_exporter --config.file /etc/blackbox_exporter/blackbox.yml

   [Install]
   WantedBy=multi-user.target
   ````
   5. Reload the systemd daemon and restart the service (on every reboot)
   ````
   sudo systemctl daemon-reload
   sudo systemctl enable blackbox_exporter
   sudo systemctl start blackbox_exporter
   sudo systemctl status blackbox_exporter   
   ````
   6. Configure Prometheus
   Edit the prometheus config /etc/prometheus/prometheus.yml and append the following (using your IPs):
   ````
   - job_name: 'blackbox'
     metrics_path: /probe
     params:
      module: [http_2xx]
     static_configs:
       - targets:
         - http://52.202.41.59.8080
         - http://52.202.41.59.5050
     relabel_configs:
       - source_labels: [__address__]
         target_label: __param_target
       - source_labels: [__param_target]
         target_label: instance
       - target_label: __address__
         replacement: localhost:9115
   ````
   7. Restart Prometheus
   ````
   sudo systemctl restart prometheus
   sudo systemctl status prometheus
   ````

## 4.5. INSTALL GRAFANA AND CONFIGURE DEMO DASHBOARDS 

   1. Update packages and create /etc/yum.repos.d/grafana.repo
   ````
   sudo yum update -y
   sudo nano /etc/yum.repos.d/grafana.repo
   ````
   2. Add the text below to the repo file
   ````
   [grafana]
   name=grafana
   baseurl=https://packages.grafana.com/oss/rpm
   repo_gpgcheck=1
   enabled=1
   gpgcheck=1
   gpgkey=https://packages.grafana.com/gpg.key
   sslverify=1
   sslcacert=/etc/pki/tls/certs/ca-bundle.crt
   ````
   3. Install Grafana and start as service
   ````
   sudo yum install grafana -y
   sudo systemctl daemon-reload
   sudo systemctl enable grafana-server
   sudo systemctl start grafana-server
   sudo systemctl status grafana-server
   ````
   4. Connect with Prometheus and import few Dashboards
   Grafana Dashboards are exposed to port :3000
   Login works with user:admin nad password:admin.
   After login, go to "Configuration" and add our Prometheus server as new data source
   As a quickstart to import the following dashboards with their IDs:
   * 11074 and/or 1860 visualizing node exporter metrics
   * 7587 visualizing blackbox exporter metrics

# 5. REFERENCES

* [How to create an EC2 instance from AWS Console](https://www.techtarget.com/searchcloudcomputing/tutorial/How-to-create-an-EC2-instance-from-AWS-Console)
* [How To Install Git In AWS EC2 Instance](https://cloudaffaire.com/how-to-install-git-in-aws-ec2-instance/)
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
