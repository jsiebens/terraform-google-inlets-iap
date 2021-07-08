#! /bin/bash

sudo sed -i "s/#Port 22/Port ${ssh_port}/" /etc/ssh/sshd_config
sudo systemctl restart sshd

export AUTHTOKEN="${token}"
export IP=$(curl -sfSL -H "Metadata-Flavor: Google" http://metadata/computeMetadata/v1/instance/network-interfaces/0/access-configs/0/external-ip)
curl -SLsf https://github.com/inlets/inlets-pro/releases/download/0.8.5/inlets-pro > /tmp/inlets-pro && \
  chmod +x /tmp/inlets-pro  && \
  mv /tmp/inlets-pro /usr/local/bin/inlets-pro

curl -sLO https://raw.githubusercontent.com/inlets/inlets-pro/master/artifacts/inlets-pro.service  && \
  mv inlets-pro.service /etc/systemd/system/inlets-pro.service && \
  echo "AUTHTOKEN=$AUTHTOKEN" >> /etc/default/inlets-pro && \
  echo "IP=$IP" >> /etc/default/inlets-pro && \
  systemctl start inlets-pro && \
  systemctl enable inlets-pro
