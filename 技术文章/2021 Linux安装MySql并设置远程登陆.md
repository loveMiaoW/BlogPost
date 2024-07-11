# Linux下安装Mysql5.7并配置远程登陆

## 系统环境

- win11 开发机器
- Centos7.6 阿里云服务器
- Mysql5.7 数据库

## 安装MySQL

CentOS 7之后的版本yum的默认源中使用[MariaDB]()替代原先[MySQL]()，因此安装方式较为以往有一些改变：

下载mysql的源

```shell
wget http://dev.mysql.com/get/mysql57-community-release-el7-7.noarch.rpm
```

安装yum库

```shell
yum localinstall -y mysql57-community-release-el7-7.noarch.rpm
```

安装MySQL

```shell
yum install -y mysql-community-server
```

可能会遇到的问题

```shell
Public key for mysql-community-libs-5.7.44-1.el7.x86_64.rpm is not installed

 Failing package is: mysql-community-libs-5.7.44-1.el7.x86_64
 GPG Keys are configured as: file:///etc/pki/rpm-gpg/RPM-GPG-KEY-mysql
```

解决方法,执行下边命令，在重新执行`yum install -y mysql-community-server`

```shell
rpm --import https://repo.mysql.com/RPM-GPG-KEY-mysql-2022
```

启动mysql服务,正常情况是没有输出

```shell
systemctl start mysqld.service
```

## 登陆Mysql

MySQL5.7加强了root用户的安全性，因此在第一次安装后会初始化一个随机密码，以下为查看初始随机密码的方式

```shell
grep 'temporary password' /var/log/mysqld.log
```

结果如下

```shell
[root@VM-16-17-centos ~]# grep 'temporary password' /var/log/mysqld.log
2024-02-05T14:46:43.536366Z 1 [Note] A temporary password is generated for root@localhost: di!kZxdwy7O0
```

使用`mysql -uroot -p` 临时登陆密码 登陆mysql

```shell
[root@VM-16-17-centos ~]# mysql -uroot -p
Enter password: 
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 2
Server version: 5.7.44

Copyright (c) 2000, 2023, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql>
```

设置root密码

```shell
SET PASSWORD = PASSWORD('@centosRoot_2021');
ALTER USER 'root'@'localhost' PASSWORD EXPIRE NEVER;
flush privileges;
```

使用`quit` 退出后可以用新密码重新登陆

## 开放远程访问权限

远程授权，更改为你自己的密码

```shell
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '@centosRoot_2021' WITH GRANT OPTION;
```

授权之后，用nevicat检查一下是否可以连接，如果不可以，可能是防火墙限制了。需要在防火墙里面加开放[数据库]()端口的规则。

## 开放端口

查看当前端口

```shell
firewall-cmd --list-all 
```

```shell
//如果输出这个，说明防火墙未开启
FirewallD is not running
//开启防火墙
service firewalld restart
//再次执行上条指令
//输出
[root@VM-16-17-centos ~]# firewall-cmd --list-all 
public
  target: default
  icmp-block-inversion: no
  interfaces: 
  sources: 
  services: dhcpv6-client ssh
  ports: 
  protocols: 
  masquerade: no
  forward-ports: 
  source-ports: 
  icmp-blocks: 
  rich rules: 

```

开放3306端口，重启防火墙

```shell
firewall-cmd --permanent --add-port=3306/tcp
service firewalld restart
```

如果是云服务器，比如阿里云或者腾讯云，需要去控制台，在安全组里开放3306端口

一般都在云服务器-> 防火墙/安全组 -> 添加规则 -> 选择放行端口3306 -> ip源0.0.0.0

## 测试连接

navicat 或者其他的app

## 总结

以上所述是给大家介绍的CentOS7.6安装MySql5.7并开启远程连接授权的教程,希望对大家有所帮助，如果大家有任何疑问请给我留言。