# download and install promtail
curl -O -L https://github.com/grafana/loki/releases/download/v2.4.1/promtail-linux-amd64.zip
sudo unzip promtail-linux-amd64.zip
sudo rm promtail-linux-amd64.zip
sudo chmod a+x promtail-linux-amd64
sudo cp promtail-linux-amd64 /usr/local/bin/promtail-linux-amd64

# create config file
sudo cp promtail_config.yml /usr/local/bin/config-promtail.yml

# create promtail user and assign admin group
sudo useradd --system promtail
sudo usermod -a -G adm promtail

# configure promtail as a service
sudo cp promtail.service /etc/systemd/system/promtail.service
sudo systemctl daemon-reload
sudo service promtail start
sudo service promtail status

