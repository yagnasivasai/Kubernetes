sudo swapoff -a
sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

hostnamectl set-hostname master
hostnamectl set-hostname worker1
hostnamectl set-hostname worker2

yum update -y && yum upgrade -y
sudo swapoff -a
sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config


Config>ApiGateway


cat /etc/rocky-release
uname -r
setenforce 0
sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config
