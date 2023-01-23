sudo cp grafana.repo /etc/yum.repos.d/grafana.repo

sudo yum update -y
sudo yum install grafana -y
sudo systemctl daemon-reload
sudo systemctl enable grafana-server
sudo systemctl start grafana-server
sudo systemctl status grafana-server