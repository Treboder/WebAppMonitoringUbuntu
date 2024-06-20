# 1. SETUP PROCEDURE STEP-BY-STEP
The entire procedure is organized in 6 sequential steps:
* 1.1. PREPARE COMPUTE RESOURCES
* 1.2. SETUP WEB APPLICATIONS
* 1.3. INSTALL PROMETHEUS
* 1.4. INSTALL BLACKBOX EXPORTER AND CONFIGURE PROMETHEUS
* 1.5. INSTALL GRAFANA AND CONFIGURE DEMO DASHBOARDS
* 1.6. Install and Configure Loki
* 1.7. Install and Configure Promtail
* 1.8. Grafana Loki Dashboard

## 1.1. PREPARE COMPUTE RESOURCES
We assume that two linux-based machines are available, one for the web applications and one for the monitoring stack.
After provisioning the compute resources, we install [Prometheus Node Exporter](https://github.com/prometheus/node_exporter) on both instances.
As a result we should see the Node Exporter endpoint exposed to port 9100 (dont forget to open the port by adjusting the security group).
1. Install Git in case you want to use the scripts and config files directly from this repo (https://github.com/Treboder/WebAppMonitoringEC2)
   ````console
   sudo yum update -y
   sudo yum install git -y
   git version
   git clone https://github.com/Treboder/WebAppMonitoringEC2
   ````
2. Create a user for Prometheus Node Exporter and install Node Exporter binaries.
   ```console
   sudo useradd --no-create-home node_exporter
   wget https://github.com/prometheus/node_exporter/releases/download/v1.0.1/node_exporter-1.0.1.linux-amd64.tar.gz
   tar xzf node_exporter-1.0.1.linux-amd64.tar.gz
   sudo cp node_exporter-1.0.1.linux-amd64/node_exporter /usr/local/bin/node_exporter
   rm -rf node_exporter-1.0.1.linux-amd64.tar.gz node_exporter-1.0.1.linux-amd64
   ```
3. Create /etc/systemd/system/node-exporter.service if it doesn’t exist.
   ```service
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
4. Configure systemd and start the servcie.
   ```console
   sudo systemctl daemon-reload
   sudo systemctl enable node_exporter
   sudo systemctl start node_exporter
   sudo systemctl status node_exporter
   ```

## 1.2. SETUP WEB APPLICATIONS
We run both apps standalone via separate Docker container, without any dependencies between them.
1. Install Docker and start as a service (on every reboot)
    ```console
    sudo yum update -y
    sudo amazon-linux-extras install docker -y
    sudo systemctl daemon-reload
    sudo systemctl enable docker   
    sudo systemctl start docker   
    sudo systemctl status docker 
    ```
2. Run Apache Server (httpd) as docker -> check welcome message on port 80
   ````console
   sudo docker pull httpd
   sudo docker run -d -p 80:80 httpd
   curl localhost:80
   ````  
3. Run an exemplary REST Service as docker -> check endpoint on port 5050
   ````console
   sudo docker pull vad1mo/hello-world-rest
   sudo docker run -d -p 5050:5050 vad1mo/hello-world-rest
   curl localhost:5050/foo/bar
   ````
4. Start web app services on every reboot automatically (--restart always)
   ````console
   sudo docker run -p 5050:5050 --name hello-world-rest -d --restart always vad1mo/hello-world-rest
   sudo docker run -p 8080:80 --name apache -d --restart always httpd
   ````

## 1.3. INSTALL PROMETHEUS

1. Create user and install Prometheus (download, extract and copy binaries before clean up)
   ```` console  
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
   Create or replace the content of /etc/prometheus/prometheus.yml.
   ````yml
   global:
    scrape_interval: 15s
    external_labels:
     monitor: 'prometheus'

   scrape_configs:
    - job_name: 'prometheus'
      static_configs:
        - targets: ['localhost:9100']
        - targets: ['your_web_server_ip:9100'] # dont forget to adjust with your IPs
   ````

3. Prepare Prometheus to run as service and therefore create file /etc/systemd/system/prometheus.service
   ````service
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

4. Start Prometheus as a service after changing the permissions and configuring systemd.
   ````console
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

## 1.4. INSTALL BLACKBOX EXPORTER AND CONFIGURE PROMETHEUS

1. Create user, install binaries and prepare config file
   ````console
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
   ````yml
   modules:
    http_2xx:
     prober: http
     timeout: 5s
     http:
      valid_status_codes: []
      method: GET
   ````
4. Create service file /etc/systemd/system/blackbox_exporter.service
   ````service
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
   ````console
   sudo systemctl daemon-reload
   sudo systemctl enable blackbox_exporter
   sudo systemctl start blackbox_exporter
   sudo systemctl status blackbox_exporter   
   ````
6. Configure Prometheus
   Edit the prometheus config */etc/prometheus/prometheus.yml* and append the following (using your IPs):
   ````yml
   - job_name: 'blackbox'
     metrics_path: /probe
     params:
      module: [http_2xx]
     static_configs:
       - targets:
         - http://your_web_server_ip:8080
         - http://your_web_server_ip:5050
     relabel_configs:
       - source_labels: [__address__]
         target_label: __param_target
       - source_labels: [__param_target]
         target_label: instance
       - target_label: __address__
         replacement: localhost:9115
   ````
7. Restart Prometheus
   ````console
   sudo systemctl restart prometheus
   sudo systemctl status prometheus
   ````

## 1.5 Install and Configure Loki (on monitoring server)
-> [Install Loki Binary and Start as a Service](https://sbcode.net/grafana/install-loki-service/)

## 1.6 Install and Configure Promtail (on application server)
-> * [Install Promtail Binary and Start as a Service](https://sbcode.net/grafana/install-promtail-service/)

## 1.7. INSTALL GRAFANA via APT (Ubuntu)

1. Install Grafana from APT repository
   ````console
sudo apt-get install -y apt-transport-https software-properties-common wget
sudo mkdir -p /etc/apt/keyrings/
wget -q -O - https://apt.grafana.com/gpg.key | gpg --dearmor | sudo tee /etc/apt/keyrings/grafana.gpg > /dev/null
echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list
sudo apt-get update
sudo apt-get install grafana
   ````

2. Start the Grafana server with systemd
   ````console
sudo systemctl daemon-reload
sudo systemctl start grafana-server
sudo systemctl status grafana-server
   ````

* https://computingforgeeks.com/how-to-install-grafana-on-ubuntu-linux-2/?utm_content=cmp-true
* https://grafana.com/docs/grafana/latest/setup-grafana/installation/debian/

## 4.8 Configure Grafana Dashboards
Connect with Prometheus and import few Dashboards
Grafana Dashboards are exposed to port :3000
Login works with user:admin and password:admin.
After login, go to "Configuration" and add our Prometheus server as new data source
As a quickstart to import the following dashboards with their IDs:
* 11074, 11133, or 1860 visualizing node exporter metrics
* 7587 visualizing blackbox exporter metrics
* 13186 Loki Dashboard