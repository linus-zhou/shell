!# /bin/bash

# 安装nginx
touch /etc/yum.repos.d/nginx.repo

echo '[nginx]\n' > /etc/yum.repos.d/nginx.repo
echo 'name=nginx repo \n' >> /etc/yum.repos.d/nginx.repo
echo 'baseurl=http://nginx.org/packages/centos/7/\$basearch/' >> /etc/yum.repos.d/nginx.repo
echo 'gpgcheck=0 \n' >> /etc/yum.repos.d/nginx.repo
echo 'enabled=1' >> /etc/yum.repos.d/nginx.repo

yum update -y
yum install nginx -y 
systemctl start nginx
systemctl enable nginx



