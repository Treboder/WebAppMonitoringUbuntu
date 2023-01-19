#!/bin/bash

echo "Install node exporter"
sh ./scripts/node_exporter_install.sh
sudo cp configs/node_exporter.service /etc/systemd/system/node_exporter.service
sh ./scripts/node_exporter_setup.sh

echo "Install docker"
sudo yum update -y
sudo amazon-linux-extras install docker -y
sudo systemctl daemon-reload
sudo systemctl enable docker   
sudo systemctl start docker   
sudo systemctl status docker 

echo "Install Apache and run as a service (always)"
sudo docker pull httpd
sudo docker run -p 8080:80 --name apache -d --restart always httpd

echo "Install Hello-World-REST and run as a service (always)"
sudo docker pull vad1mo/hello-world-rest
sudo docker run -p 5050:5050 --name hello-world-rest -d --restart always vad1mo/hello-world-rest
