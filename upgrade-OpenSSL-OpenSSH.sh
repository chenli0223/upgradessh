#!/bin/bash

############################################
#############   升级OpenSSL      ###########
############################################

#查看ssl版本及安装编译工具、下载OpenSSL源码包
openssl version -a
yum install -y gcc openssl-devel pam-devel rpm-build
wget https://distfiles.macports.org/openssl/openssl-1.0.2q.tar.gz /root
tar -zxvf /root/openssl-1.0.2q.tar.gz -C /usr

#卸载当前版本openssl
rpm -qa | grep openssl
rpm -qa |grep openssl|xargs -i rpm -e --nodeps {}

#编译安装新版openssl 
cd /usr/openssl-1.0.2q
./config --prefix=/usr --openssldir=/etc/ssl --shared zlib
make && make test && make install

#创建库文件软链接并查看版本
ll /usr/lib64/libssl.so*
ll /usr/lib64/libcrypto.so*
ln -s /usr/lib64/libssl.so.1.0.0  libssl.so.10
ln -s /usr/lib64/libcrypto.so.1.0.0  libcrypto.so.10
openssl version -a

##########################################
################ 升级OpenSSH  ############
##########################################

#查看版本并安装编译工具、下载源码包
ssh -V
yum install -y gcc openssl-devel pam-devel rpm-build
wget http://ftp.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-7.9p1.tar.gz /root

#删除原openssh软件
rm -rf /etc/ssh
rpm -qa |grep openssh
for i in `rpm -qa |grep openssh`;do rpm -e $i --nodeps;done

#安装openssh源码包
tar -zxvf /root/openssh-7.9p1.tar.gz -C /usr
cd /usr/openssh-7.9p1
./configure --prefix=/usr --sysconfdir=/etc/ssh --with-md5-passwords --with-pam --with-tcp-wrappers  --without-hardening
make && make install

#配置并重启openssh，查看版本
rm -rf /etc/init.d/sshd
cp /usr/openssh-7.9p1/contrib/redhat/sshd.init /etc/init.d/sshd
chkconfig --add sshd
chkconfig --list|grep sshd
echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
systemctl enable sshd
systemctl restart sshd
systemctl status sshd
ssh -V


