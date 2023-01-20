#!/bin/bash

echo "Install node exporter"
sh ./scripts/node_exporter_install.sh
sudo cp configs/node_exporter.service /etc/systemd/system/node_exporter.service
sh ./scripts/node_exporter_setup.sh

echo "install blackbox exporter"
sh ./scripts/blackbox_exporter_install.sh
sudo cp configs/blackbox.yml /etc/blackbox_exporter/blackbox.yml
sudo cp configs/blackbox_exporter.service /etc/systemd/system/blackbox_exporter.service
sh ./scripts/blackbox_exporter_setup.sh

echo "install Prometheus"
sh ./scripts/prometheus_install.sh
sudo cp configs/prometheus.yml /etc/prometheus/prometheus.yml
sudo cp configs/prometheus.service /etc/systemd/system/prometheus.service
sh ./scripts/prometheus_setup.sh

echo "install Grafana"
sudo cp configs/grafana.repo /etc/yum.repos.d/grafana.repo
sh ./scripts/grafana_install.sh
