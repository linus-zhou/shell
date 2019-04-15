!# /bin/bash

# 安装nginx
touch /etc/yum.repos.d/nginx.repo

echo '[nginx]' > /etc/yum.repos.d/nginx.repo
echo 'name=nginx repo' >> /etc/yum.repos.d/nginx.repo
echo 'baseurl=http://nginx.org/packages/centos/7/$basearch/' >> /etc/yum.repos.d/nginx.repo
echo 'gpgcheck=0' >> /etc/yum.repos.d/nginx.repo
echo 'enabled=1' >> /etc/yum.repos.d/nginx.repo

yum update -y
yum install nginx -y 

# 创建存放文件夹
mkdir /usr/share/nginx/files

# 重命名默认配置文件
mv /etc/nginx/conf.d/default.conf  /etc/nginx/conf.d/default.conf.bk

touch /etc/nginx/conf.d/file_server.conf

echo 'limit_conn_zone $binary_remote_addr zone=addr:10m;' > /etc/nginx/conf.d/file_server.conf
echo 'server {' >> /etc/nginx/conf.d/file_server.conf
echo 'listen       80;' >> /etc/nginx/conf.d/file_server.conf
echo 'server_name  localhost;' >> /etc/nginx/conf.d/file_server.conf
echo 'location / {' >> /etc/nginx/conf.d/file_server.conf
echo 'root /usr/share/nginx/html;'  >> /etc/nginx/conf.d/file_server.conf
echo 'index index.html;' >> /etc/nginx/conf.d/file_server.conf
echo '}' >> /etc/nginx/conf.d/file_server.conf
echo 'location /files {' >> /etc/nginx/conf.d/file_server.conf
echo 'alias /usr/share/nginx/files;' > /etc/nginx/conf.d/file_server.conf
echo 'limit_conn addr 2;' > /etc/nginx/conf.d/file_server.conf
echo 'limit_rate_after 20m;' > /etc/nginx/conf.d/file_server.conf
echo 'limit_rate 100k;' > /etc/nginx/conf.d/file_server.conf
echo 'charset utf-8;' > /etc/nginx/conf.d/file_server.conf
echo '}' > /etc/nginx/conf.d/file_server.conf
echo '}' > /etc/nginx/conf.d/file_server.conf

systemctl start nginx
systemctl enable nginx





