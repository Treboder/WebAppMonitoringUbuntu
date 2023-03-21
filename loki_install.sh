# donwload and install loki
curl -O -L https://github.com/grafana/loki/releases/download/v2.4.1/loki-linux-amd64.zip
sudo unzip loki-linux-amd64.zip
sudo rm loki-linux-amd64.zip
sudo chmod a+x loki-linux-amd64
sudo cp loki-linux-amd64 /usr/local/bin/loki-linux-amd64

# create config
sudo sudo useradd --system loki
sudo cp loki_config.yml /usr/local/bin/config-loki.yml

# configure loki as a service
sudo cp loki.service /etc/systemd/system/loki.service
sudo systemctl daemon-reload
sudo systemctl enable loki
sudo systemctl start loki
sudo systemctl status loki