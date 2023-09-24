#!/bin/bash
# Adding swap temporarily in case of using t3.nano
dd if=/dev/zero of=/var/cache/swapfile bs=1M count=1024;
chmod 600 /var/cache/swapfile;
mkswap /var/cache/swapfile;
swapon /var/cache/swapfile;
free -m > /var/tmp/swap.txt
apt-get update && apt-get upgrade -y
apt-get install wget unzip -y
sed -i 's/^#Port 22/Port 2020/g' /etc/ssh/sshd_config;
systemctl restart sshd;
hostnamectl set-hostname ${project_name};
timedatectl set-timezone Europe/London;
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
wget -4 https://s3.amazonaws.com/mountpoint-s3-release/latest/x86_64/mount-s3.deb
sudo apt-get install -y ./mount-s3.deb 
mkdir /mnt/s3
mount-s3 ${bucket_name} /mnt/s3
