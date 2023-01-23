sudo useradd --no-create-home --shell /bin/false blackbox_exporter
wget https://github.com/prometheus/blackbox_exporter/releases/download/v0.14.0/blackbox_exporter-0.14.0.linux-amd64.tar.gz
tar -xvf blackbox_exporter-0.14.0.linux-amd64.tar.gz
sudo cp blackbox_exporter-0.14.0.linux-amd64/blackbox_exporter /usr/local/bin/blackbox_exporter
sudo chown blackbox_exporter:blackbox_exporter /usr/local/bin/blackbox_exporter
rm -rf blackbox_exporter-0.14.0.linux-amd64*   
sudo mkdir /etc/blackbox_exporter
sudo touch /etc/blackbox_exporter/blackbox.yml
sudo chown blackbox_exporter:blackbox_exporter /etc/blackbox_exporter/blackbox.yml

sudo cp blackbox.yml /etc/blackbox_exporter/blackbox.yml
sudo cp blackbox_exporter.service /etc/systemd/system/blackbox_exporter.service

sudo systemctl daemon-reload
sudo systemctl enable blackbox_exporter
sudo systemctl start blackbox_exporter
sudo systemctl status blackbox_exporter