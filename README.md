# INTRODUCION
This demo projects shows how to setup a basic monitoring scenario based on [Prometheus](https://prometheus.io/) and [Grafana](https://grafana.com/).
The idea is to monitor the health of web applications, in this case a [Apache Web Server](https://httpd.apache.org/) in its most basic configuration.
We also show how to monitor an exemplary [Hello World REST Service](https://hub.docker.com/r/vad1mo/hello-world-rest/). 
Both web applications mentioned are supposed to run via [Docker](https://hub.docker.com/) on the same EC2 instance, 
whereas [Prometheus](https://prometheus.io/) and [Grafana](https://grafana.com/) are installed and configured on another EC2.

# ARCHITECTURE

tbd image

# PREPARE COMPUTE RESOURCES
We assume that two linux-based machines are available, one for the web applications and one for the monitoring stack.
After provisioning the compute resources, we install [Prometheus Node Exporter](https://github.com/prometheus/node_exporter) on both instances.
As a result we should see the Node Exporter endpoint exposed to port 9100 (dont forget to open the port by adjusting the security group).
 1. Create a user for Prometheus Node Exporter and install Node Exporter binaries 
    -> [cf. scripts/node exporter install.sh](scripts/node%20exporter%20install.sh)
    ```
    sudo useradd --no-create-home node_exporter
    wget https://github.com/prometheus/node_exporter/releases/download/v1.0.1/node_exporter-1.0.1.linux-amd64.tar.gz
    tar xzf node_exporter-1.0.1.linux-amd64.tar.gz
    sudo cp node_exporter-1.0.1.linux-amd64/node_exporter /usr/local/bin/node_exporter
    rm -rf node_exporter-1.0.1.linux-amd64.tar.gz node_exporter-1.0.1.linux-amd64
    ```
 2. Create /etc/systemd/system/node-exporter.service if it doesn’t exist
    -> [cf. scripts/node-exporter.service](scripts/node-exporter.service)
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
 3. Configure systemd and start the servcie
    -> [cf. scripts/node exporter setup.sh](scripts/node%20exporter%20setup.sh)   
    ```
    sudo systemctl daemon-reload
    sudo systemctl enable node-exporter
    sudo systemctl start node-exporter
    sudo systemctl status node-exporter
    ```

# SETUP WEB APPLICATIONS
We run both apps standalone via separate Docker container, without any dependencies between them.   
1. Install and start Docker
    ```
    sudo yum update -y
    sudo amazon-linux-extras install docker -y
    sudo service docker start
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
4. Autostart all services (docker, httpd, and REST Service) -> tbd
   * docker.service
   * httpd.service
   * hello-world-rest.service

# INSTALL PROMETHEUS
   
   1. Create user and install Prometheus (download, extract and copy binaries before clean up)
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
   
   2. Create or replace the content of /etc/prometheus/prometheus.yml
   ````
   ````
   
   3. Create /etc/systemd/system/prometheus.service
   ````
   ````
   
   4. Change the permissions and configure systemd 
   ````
   sudo chown prometheus:prometheus /etc/prometheus
   sudo chown prometheus:prometheus /usr/local/bin/prometheus
   sudo chown prometheus:prometheus /usr/local/bin/promtool
   sudo chown -R prometheus:prometheus /etc/prometheus/consoles
   sudo chown -R prometheus:prometheus /etc/prometheus/console_libraries
   sudo chown -R prometheus:prometheus /var/lib/prometheus
   
   sudo systemctl daemon-reload
   sudo systemctl enable prometheus   
   ````
   
# INSTALL BLACKBOX EXPORTER AND CONFIGURE PROMETHEUS

# INSTALL GRAFANA AND CONFIGURE DEMO DASHBOARDS AND ALERTING

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
