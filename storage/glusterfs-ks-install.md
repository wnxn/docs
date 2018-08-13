# 部署Glusterfs存储服务端
> 此安装方法仅供测试Kubesphere，搭建Glusterfs集群请参考Glusterfs[官方网站](https://docs.gluster.org/en/latest/)，搭建 Heketi 请参考[官方文档](https://github.com/heketi/heketi/blob/master/docs/admin/readme.md)

## 准备材料
机器资源

|hostname        |IP     |OS       |device|
|:---------------:|:------:|:------:|:---:|
|glusterfs-server1  |172.20.1.5|Ubuntu16.04.4| /dev/vda 100Gi, /dev/vdc 300Gi|
|glusterfs-server2  |172.20.1.6|Ubuntu16.04.4| /dev/vda 100Gi, /dev/vdc 300Gi|


```
  +-----------------------+               +-----------------------+
  |                       |               |                       |
  |   glusterfs-server1   |_______________|   glusterfs-server2   |
  |        heketi         |               |                       |
  |                       |               |                       |
  +-----------------------+               +-----------------------+
```

> 如需创建更大容量Glusterfs存储服务端，可挂载更大容量块存储至主机

## 安装步骤
- 将要安装ceph 10.2.10
- Glusterfs服务端将数据存储至/dev/vdc块设备中，/dev/vdc必须是未经分区格式化的原始块设备

### 配置 root 账户登录（glusterfs-server1，glusterfs-server2）
- ubuntu账户登录主机后切换root账户
```
ubuntu@glusterfs-server1:~$ sudo -i
[sudo] password for ubuntu: 
root@glusterfs-server1:~# 
```

```
ubuntu@glusterfs-server2:~$ sudo -i
[sudo] password for ubuntu: 
root@glusterfs-server2:~# 
```

- 设置 root 账户登录密钥
```
root@glusterfs-server1:~# passwd
Enter new UNIX password: 
Retype new UNIX password: 
passwd: password updated successfully
```
```
root@glusterfs-server2:~# passwd
Enter new UNIX password: 
Retype new UNIX password: 
passwd: password updated successfully
```

### 修改 hosts 文件（glusterfs-server1，glusterfs-server2）
```
root@glusterfs-server1:~# vi /etc/hosts
127.0.0.1	localhost

# The following lines are desirable for IPv6 capable hosts
::1     localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters

# hostname loopback address
172.20.1.5	    glusterfs-server1
172.20.1.6      glusterfs-server2
```

```
root@glusterfs-server2:~# cat /etc/hosts
127.0.0.1	localhost

# The following lines are desirable for IPv6 capable hosts
::1     localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters

# hostname loopback address
172.20.1.5	    glusterfs-server1
172.20.1.6      glusterfs-server2
```


### 配置 glusterfs-server1 无密码登录至 glusterfs-server1 与 glusterfs-server2 （glusterfs-server1）
- 创建密钥，提示 “Enter passphrase” 时，直接回车，口令即为空
```
root@glusterfs-server1:~# ssh-keygen
Generating public/private rsa key pair.
Enter file in which to save the key (/root/.ssh/id_rsa): 
Created directory '/root/.ssh'.
Enter passphrase (empty for no passphrase): 
Enter same passphrase again: 
Your identification has been saved in /root/.ssh/id_rsa.
Your public key has been saved in /root/.ssh/id_rsa.pub.
The key fingerprint is:
SHA256:hjy5ufMskYNC4XZbELk0tecMOBLoHEPqEQgmCi7gDHc root@glusterfs-server1
The key's randomart image is:
+---[RSA 2048]----+
|X=o E+.          |
|#+oo=. .         |
|**+oo+o .        |
|oo=.oo.B         |
| + . +=.S        |
|  . o +=         |
|   .  oo         |
|      oo         |
|      .+o        |
+----[SHA256]-----+

```

- 拷贝密钥到各个 Ceph 节点，按照提示输入密钥
```
root@glusterfs-server1:~# ssh-copy-id root@glusterfs-server1
...
root@glusterfs-server1:~# ssh-copy-id root@glusterfs-server2
...
```

- 验证，glusterfs-server1 无需输入密码可以登录 glusterfs-server1，glusterfs-server2
```
root@glusterfs-server1:~# ssh root@glusterfs-server1
root@glusterfs-server1:~# ssh root@glusterfs-server2
```

### 安装Glusterfs

```
root@glusterfs-server1:~# apt-get install glusterfs-server -y
```

```
root@glusterfs-server2:~# apt-get install glusterfs-server -y
```

> 检查
```
root@glusterfs-server1:~# glusterfs -V
glusterfs 3.7.6 built on Dec 25 2015 20:50:44
...
```

```
root@glusterfs-server2:~# glusterfs -V
glusterfs 3.7.6 built on Dec 25 2015 20:50:44
...
```

### 创建Glusterfs集群
```
root@glusterfs-server1:~# gluster peer probe glusterfs-server2
peer probe: success. 
```

```
root@glusterfs-server2:~# gluster peer probe glusterfs-server1
peer probe: success. Host glusterfs-server1 port 24007 already in peer list
```

> 检查状态
```
root@glusterfs-server1:~# gluster peer status
Number of Peers: 1

Hostname: glusterfs-server2
Uuid: aeccd9c9-0311-4133-9f0a-80d4a04c8b49
State: Peer in Cluster (Connected)
```

```
root@glusterfs-server2:~# gluster peer status
Number of Peers: 1

Hostname: glusterfs-server1
Uuid: 746e4e7f-6f5b-4303-aeeb-f6bef84e7e29
State: Peer in Cluster (Connected)
```

