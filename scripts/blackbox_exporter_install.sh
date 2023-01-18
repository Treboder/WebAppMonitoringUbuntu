   useradd --no-create-home --shell /bin/false blackbox_exporter
   wget https://github.com/prometheus/blackbox_exporter/releases/download/v0.14.0/blackbox_exporter-0.14.0.linux-amd64.tar.gz
   tar -xvf blackbox_exporter-0.14.0.linux-amd64.tar.gz
   cp blackbox_exporter-0.14.0.linux-amd64/blackbox_exporter /usr/local/bin/blackbox_exporter
   chown blackbox_exporter:blackbox_exporter /usr/local/bin/blackbox_exporter
   rm -rf blackbox_exporter-0.14.0.linux-amd64*   
   mkdir /etc/blackbox_exporter
   vim /etc/blackbox_exporter/blackbox.yml
   chown blackbox_exporter:blackbox_exporter /etc/blackbox_exporter/blackbox.yml