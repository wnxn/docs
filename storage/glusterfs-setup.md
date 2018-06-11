# GlusterFS
本文旨在部署GlusterFS集群供Kubernetes的动态分配存储使用。
由于Kubernetes动态分配需要使用Heketi service所以包含GlusterFS和Heketi的安装。

机器资源

|hostname        |IP     |OS       |device|
|-----------------|--------|--------|-----|
|heketi           |192.168.1.19|Fedora24|  NULL  |
|glusterfs-server1|192.168.1.16|Fedora24|/dev/sdd 80GiB|
|glusterfs-server2|192.168.1.17|Fedora24|/dev/sdd 90GiB|

常用命令
```
fdisk -l //查看磁盘设备
df -lha //查看挂载设备
heketi-cli cluster list
heketi-cli cluster info XXX
heketi-cli node list
heketi-cli node info XXX
heketi-cli device info XXX
```

## GlusterFS安装
在glusterfs-server1和glusterfs-server2进行如下操作
### 编辑/etc/hosts
```
cat /etc/hosts
192.168.1.16  glusterfs-server1
192.168.1.17  glusterfs-server2
```
### 安装软件
```
yum install glusterfs-server
service glusterd start
service glusterd status
```

### 配置网络
方法一：关闭防火墙
```
systemctl stop firewalld
systemctl disable firewalld
systemctl status firewalld
```

方法二：需要访问glusterfs节点的主机均要在glusterfs节点配置此规则
```
iptables -I INPUT -p all -s <actual ip addr> -j ACCEPT
```

### 配置trusted pool
在glusterfs-server1上
```
gluster peer probe glusterfs-server2
```
在glusterfs-server2上
```
gluster peer probe glusterfs-server1
```
检查状态
```
gluster peer status
```

## Heketi安装
以下操作均在Heketi节点执行
注: 执行操作用户应与Heketi启动用户一致
### 编辑/etc/hosts
```
cat /etc/hosts
192.168.1.16  glusterfs-server1
192.168.1.17  glusterfs-server2
```

### 生成密钥
```
ssh-keygen
```

### 拷贝公钥至glusterfs节点
需要输入glusterfs节点登录密码
```
ssh-copy-id -i ~/.ssh/id_rsa.pub root@192.168.1.16
ssh-copy-id -i ~/.ssh/id_rsa.pub root@192.168.1.17
```

如出现`ERROR: /etc/ssh/ssh_config line 35: garbage at end of line; "UserKnownHostsFile".`
编辑/etc/ssh/ssh_config，注释35行，允许ssh登录

验证免密登录
```
ssh root@192.168.1.16
```

### 下载Heketi
```
yum install heketi heketi-client
```

### 编辑heketi配置文件
```
cat /etc/heketi/heketi.json
{
  "_port_comment": "Heketi Server Port Number",
  "port": "8080",

  "_use_auth": "Enable JWT authorization. Please enable for deployment",
  "use_auth": false,

  "_jwt": "Private keys for access",
  "jwt": {
    "_admin": "Admin has access to all APIs",
    "admin": {
      "key": "123456"
    },
    "_user": "User only has access to /volumes endpoint",
    "user": {
      "key": "123456"
    }
  },

  "_glusterfs_comment": "GlusterFS Configuration",
  "glusterfs": {
    "_executor_comment": [
      "Execute plugin. Possible choices: mock, ssh",
      "mock: This setting is used for testing and development.",
      "      It will not send commands to any node.",
      "ssh:  This setting will notify Heketi to ssh to the nodes.",
      "      It will need the values in sshexec to be configured.",
      "kubernetes: Communicate with GlusterFS containers over",
      "            Kubernetes exec api."
    ],
    "executor": "ssh",

    "_sshexec_comment": "SSH username and private key file information",
    "sshexec": {
      "keyfile": "/root/.ssh/id_rsa",
      "user": "root"
    },

    "_kubeexec_comment": "Kubernetes configuration",
    "kubeexec": {
      "host" :"https://kubernetes.host:8443",
      "cert" : "/path/to/crt.file",
      "insecure": false,
      "user": "kubernetes username",
      "password": "password for kubernetes user",
      "namespace": "OpenShift project or Kubernetes namespace",
      "fstab": "Optional: Specify fstab file on node.  Default is /etc/fstab"
    },

    "_db_comment": "Database file name",
    "db": "/var/lib/heketi/heketi.db",
    "brick_max_size_gb" : 1024,
	"brick_min_size_gb" : 1,
	"max_bricks_per_volume" : 33,


    "_loglevel_comment": [
      "Set log level. Choices are:",
      "  none, critical, error, warning, info, debug",
      "Default is warning"
    ],
    "loglevel" : "debug"
  }
}

```

### 启动Heketi
注：可修改Heketi启动文件/usr/lib/systemd/system/heketi.service，Heketi的启动用户
注：可能要增加glusterfs节点的iptables ACCEPT规则
```
systemctl start heketi
systemctl status heketi
systemctl enable heketi
```

### 编辑集群拓扑文件
```
cat /usr/share/heketi/topology-sample.json
{
  "clusters": [
    {
      "nodes": [
        {
          "node": {
            "hostnames": {
              "manage": [
                "192.168.1.16"
              ],
              "storage": [
                "192.168.1.16"
              ]
            },
            "zone": 1
          },
          "devices": [
            "/dev/sdd"
          ]
        },
        {
          "node": {
            "hostnames": {
              "manage": [
                "192.168.1.17"
              ],
              "storage": [
                "192.168.1.17"
              ]
            },
            "zone": 1
          },
          "devices": [
            "/dev/sdd"
          ]
        }
      ]
    }
  ]
}

```

### 载入拓扑结构
```
# export HEKETI_CLI_SERVER=http://localhost:8080
# heketi-cli topology load --json=/etc/heketi/topology.json
	Found node 192.168.1.16 on cluster 868755d558cb7326c6d8d6ce3927a493
		Adding device /dev/sdd ... OK
	Found node 192.168.1.17 on cluster 868755d558cb7326c6d8d6ce3927a493
		Adding device /dev/sdd ... OK
# heketi-cli node list
```

参考资料：
1. GlusterFS快速安装文档: https://docs.gluster.org/en/latest/Quick-Start-Guide/Quickstart/
2. Red-hat Heketi: https://access.redhat.com/documentation/en-us/red_hat_gluster_storage/3.1/html/administration_guide/ch06s02
3. IBM glusterfs配置：https://www.ibm.com/support/knowledgecenter/en/SSBS6K_2.1.0/installing/storage_settings.html
4. GlusterFS与Heketi分开部署：https://blog.csdn.net/liukuan73/article/details/78477520