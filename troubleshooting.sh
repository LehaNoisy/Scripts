#!/bin/bash
#pls_fixme
sed -i '/export PS1/d' /root/.bashrc
sed -i '/export PS1/d' /root/.bash_profile
sed -i '/export PS1/d' /home/vagrant/.bashrc
sed -i '/export PS1/d' /home/vagrant/.bash_profile
sed -i '/export PS1/d' /home/tomcat/.bashrc
sed -i '/export PS1/d' /home/tomcat/.bash_profile
sed -i '/export PS1/d' /etc/profile
sed -i '/export PS1/d' /etc/profile.d/ps1_new.sh
echo “export PS1=\”\\u@\\H:\\w\\$ \ “” >> /etc/profile.d/ps1_new.sh 

#httpd
#delete modules
sudo sed -i '/LoadModule authnz_ldap_module/d'  /etc/httpd/conf/httpd.conf
sudo sed -i '/LoadModule log_config_module/d'  /etc/httpd/conf/httpd.conf
sudo sed -i '/LoadModule disk_cache_module /d'  /etc/httpd/conf/httpd.conf
sudo sed -i '/LoadModule authn_alias_module/d'  /etc/httpd/conf/httpd.conf
sudo sed -i '/LoadModule authn_default_module/d'  /etc/httpd/conf/httpd.conf
sudo sed -i '/LoadModule authz_default_module/d'  /etc/httpd/conf/httpd.conf
sudo sed -i '/LoadModule ldap_module/d'  /etc/httpd/conf/httpd.conf


#include selected lines at mpm_worker
sudo sed -i 's/LoadModule mpm_prefork_module/#LoadModule mpm_prefork_module/' /etc/httpd/conf.modules.d/00-mpm.conf
sudo sed -i 's/#LoadModule mpm_worker_module/LoadModule mpm_worker_module/' /etc/httpd/conf.modules.d/00-mpm.conf
sed -i '$aInclude conf.modules.d/*.conf' /etc/httpd/conf/httpd.conf

#change vhost conf
sudo sed -i 's/<VirtualHost mntlab:80>/<VirtualHost *:80>/' /etc/httpd/conf.d/vhost.conf
sudo sed -i '25i\\ServerName mntlab' /etc/httpd/conf.d/vhost.conf

#change worker.properties
sudo sed -i 's/worker.worker.host=192.168.56.100/worker.tomcat.worker.host=192.168.56.10/' /etc/httpd/conf.d/workers.properties
sudo sed -i 's/worker.worker.reference=worker.template/worker.tomcat.worker.reference=worker.template/' /etc/httpd/conf.d/workers.properties
sudo sed -i 's/worker.worker.port=8009/worker.tomcat.worker.port=8009/' /etc/httpd/conf.d/workers.properties



#Start httpd
sudo systemctl start httpd.service


#find Tomcat service
path_startup_tomcat=$(find / -type f -name startup.sh)
path_tomcat=${path_startup_tomcat:0:(${#path_startup_tomcat}-10)}
#make it all executable
chmod +x $path_tomcat*.sh
echo $path_tomcat

#set JAVA_HOME
wrong_java=`update-alternatives --display java`
echo $wrong_java
some_string=$(echo $wrong_java | grep -oE 'version is .*')
echo $some_string
java_home=$(echo ${some_string##v*s})
java_home=${java_home:0:(${#java_home}-9)}
session_java="JAVA_HOME=$java_home"
echo $session_java
sed -i -e "s#JAVA_HOME=/.*#${session_java}#g" /etc/environment
sed -i -e "s#CATALINA_HOME=/.*#CATALINA_HOME=\"\"#g" /etc/environment


#start Tomcat
$path_tomcat/./startup.sh


#Iptables

rm -f /etc/cron.d/1minutely;
  chattr -i /etc/sysconfig/iptables;
  iptables -A INPUT -p tcp -m tcp --dport 443 -j ACCEPT;
  iptables -A INPUT -p tcp -m tcp --dport 80 -j ACCEPT;
  iptables -A INPUT -p tcp -m tcp --dport 22 -j ACCEPT;
  sudo /sbin/service iptables save sudo; 
  systemctl start iptables.service;


#start services
systemctl enable httpd.service
systemctl enable iptables.service



















