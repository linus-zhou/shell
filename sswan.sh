yum -y install strongswan openssl

strongswan pki --gen --type rsa --size 4096 --outform pem > ca.key.pem
strongswan pki --self --in ca.key.pem --dn "C=CN, O=Linux strongSwan, CN=VPN CA" --ca --lifetime 3650  --type rsa --outform pem > ca.cert.pem


strongswan pki --gen --type rsa --size 4096 --outform pem > server.key.pem
strongswan pki --pub --in server.key.pem --outform pem > server.pub.pem
strongswan pki --pub --in server.key.pem | strongswan pki --issue --lifetime 3650 --cacert ca.cert.pem \
--cakey ca.key.pem --dn "C=CN, O=Linux strongSwan, CN=10.1.1.2" \
--san="10.1.1.2" --san="10.1.1.2" --flag serverAuth --flag ikeIntermediate \
--outform pem > server.cert.pem

cp -r ca.key.pem /etc/strongswan/ipsec.d/private/
cp -r ca.cert.pem /etc/strongswan/ipsec.d/cacerts/
cp -r server.cert.pem /etc/strongswan/ipsec.d/certs/
cp -r server.pub.pem /etc/strongswan/ipsec.d/certs/
cp -r server.key.pem /etc/strongswan/ipsec.d/private/

vim /etc/strongswan/ipsec.conf

config setup
        # strictcrlpolicy=yes    # 是否严格执行证书吊销规则
        uniqueids = never        # 如果同一个用户在不同的设备上重复登录,yes 断开旧连接,创建新连接;no 保持旧连接,并发送通知; never 同 no, 但不发送通知.
conn %default

        compress = yes                  # 是否启用压缩, yes 表示如果支持压缩会启用
        dpdaction = clear                # 当意外断开后尝试的操作
        dpddelay = 30s                  # dpd时间间隔
        inactivity = 300s               # 闲置时长,超过后断开连接
        left = %any                     # 服务器端标识，可以是魔术字 %any，表示从本地ip地址表中取
        leftid = 10.1.1.2               # 服务器端ID标识
        leftsubnet = 0.0.0.0/0          # 服务器端虚拟IP，0.0.0.0/0表示通配
        leftcert = server.cert.pem      # 服务器端证书 
        right=%any                      # 客户端标识，%any表示任意
        rightsourceip=192.168.99.0/24       # 客户端IP地址分配范围

conn IKEv2-EAP
        keyexchange = ikev2             # 使用 IKEv2
        leftca = "C=CN, O=Linux strongSwan, CN=VPN CA" # 服务器端根证书DN名称
        leftsendcert = always           # 是否发送服务器证书到客户端
        rightsendcert = never           # 客户端不发送证书
        left=%any                       # 服务器端标识,%any表示任意
        leftauth=pubkey                 # 服务器校验方式，使用证书
        rightauth=eap-mschapv2          #KEv2 EAP(Username/Password)
        eap_identity = %any             # 指定客户端eap id
        rekey = no                      # 不自动重置密钥
        auto = add                      # 当服务启动时, 应该如何处理这个连接项,add 添加到连接表中
        ike = aes256-aes128-3des-sha1-modp1024!
                                        # 密钥交换协议加密算法列表，可以包括多个算法和协议。
                                        # 5.0.2增加了配置与完整性保护定义的PRF算法不同的PRF算法的能力。
        esp = aes256-3des-sha256-sha1!  
                                        # 数据传输协议加密算法列表,对于IKEv2，可以在包含相同类型的多个算法（由-分隔）。
                                        # IKEv1仅包含协议中的第一个算法。只能使用ah或esp关键字，不支持AH+ESP。

# 内核转发
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
echo "net.ipv6.conf.all.forwarding = 1" >> /etc/sysctl.conf
sysctl -p

firewall-cmd --permanent --add-service="ipsec"
firewall-cmd --permanent --add-port=500/udp
firewall-cmd --permanent --add-port=4500/udp
firewall-cmd --permanent --add-masquerade
firewall-cmd --reload

systemctl start strongswan
systemctl enable strongswan