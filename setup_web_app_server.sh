#!/bin/bash
echo "Install node exporter"
sh ./scripts/node_exporter_install.sh
sudo cp configs/node_exporter.service /etc/systemd/system/node-exporter.service
sh ./scripts/node_exporter_setup.sh