# Ceph setup

## Ceph结构
- OSD：必备，Ceph OSD守护进程，1.与其他OSD守护进程建立心跳，2.向Monitor提供监控信息，3.默认3个副本
- Monitors：必备，维护集群状态图表
- MDSs：cephfs必备，Ceph元数据服务器，1.为Ceph文件系统存储元数据，执行ls，find命令不造成负担

## 步骤一：环境准备
### 申请机器
4台ubuntu 14主机，2 CPU 2G RAM。
```
                               _______________
                              |               |
                     |------->|     node1     |
                     |        |    monitor    |
                     |        |_______________|
  ____________       |         _______________
 |            |      |        |               |
 |    admin   |------|------->|      node2    |
 | ceph-deploy|      |        |      OSD.0    |
 |____________|      |        |_______________|
                     |         _______________
                     |        |               |
                     |------->|      node3    |
                              |      OSD.1    |
                              |_______________|

```

### admin节点安装`ceph-deploy`工具

#### 增加release key
```
  wget -q -O- 'https://download.ceph.com/keys/release.asc' | sudo apt-key add -
```
#### 添加Ceph包到库中
```
  echo deb https://download.ceph.com/debian-luminous/ $(lsb_release -sc) main | sudo tee /etc/apt/sources.list.d/ceph.list
```
#### 更新库并安装ceph-deploy
```
  sudo apt-get update
  sudo apt-get install ceph-deploy
```

### Ceph nodes安装工具
ntp用作对时工具，ssh用来admin节点免密登录node节点
#### 安装ntp
```
 sudo apt-get update
 sudo apt-get install ntp     //安装ntp
 sudo /etc/init.d/ntp status  //查看ntp服务状态
```
#### 安装ssh服务器
```
 sudo apt-get install openssh-server
```

### 配置免密登录
#### node中

  - *在每个node节点增加deploy用户*

  ```
   sudo echo "${CEPH_ADMIN_IP} {CEPH_ADMIN_HOSTNAME}" >> /etc/hosts
   sudo useradd -d /home/deploy -m deploy
   sudo passwd deploy // 接着输入deploy密钥
   echo "deploy ALL = (root) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/deploy
   sudo chmod 0440 /etc/sudoers.d/deploy
  ```

#### admin中
- 修改/etc/hosts

```
# cat /etc/hosts
${ADMIN IP} admin
${NODE1 IP} node1
${NODE2 IP} node2
${NODE3 IP} node3
```

- 生成ssh-key，提示 “Enter passphrase” 时，直接回车，口令即为空：

```
ssh-keygen
```

- 拷贝SSH密钥到各个Ceph节点

```
ssh-copy-id deploy@node1
```

- 为ceph-deploy方便部署,简化ssh登录

```
# cat ~/.ssh/config
Host node1
   Hostname node1
   User deploy
Host node2
   Hostname node2
   User deploy
Host node3
   Hostname node3
   User deploy
```


## 步骤二：部署存储集群
### admin中创建部署配置目录
执行部署命令时均要在此文件夹内操作。
```
mkdir my-cluster
cd my-cluster
```
### 创建集群
```
 ceph-deploy new node1
```

#### 修改ceph.conf配置文件
```
# cat ~/my-cluster/ceph.config
[省略]
osd pool default size = 2
```

#### 安装ceph
```
ceph-deploy install admin node1 node2 node3
```

#### 配置初始monitor
```
ceph-deploy mon create-initial
```

### 登录node配置节点
```
ssh node2 // 登录node2
sudo mkdir /var/local/osd0
exit

ssh node3 // 登录node3
sudo mkdir /var/local/osd1
exit
```

### admin部署集群
#### 准备OSD
```
ceph-deploy osd prepare node2:/var/local/osd0 node3:/var/local/osd1
```
 *. 安装步骤中有任何WARNING需引起重视并解决 .*

#### 激活OSD
```
ceph-deploy osd activate node2:/var/local/osd0 node3:/var/local/osd1
```

### admin将密钥拷贝到admin和node
```
ceph-deploy admin admin-node node1 node2 node3
```
#### 确保对ceph.client.admin.keyring 有正确的操作权限
```
sudo chmod +r /etc/ceph/ceph.client.admin.keyring
```

#### 查看集群健康状况
集群应该达到 active + clean 状态。
```
ceph health
```

### 扩展集群
达到3个mon节点，3个OSD
```
                               _______________
                              |               |
                     |------->|     node1     |
                     |        |   mon，osd.2  |
                     |        |_______________|
  ____________       |         _______________
 |            |      |        |               |
 |    admin   |------|------->|     node2     |
 | ceph-deploy|      |        |   mon，osd.0  |
 |____________|      |        |_______________|
                     |         _______________
                     |        |               |
                     |------->|     node3     |
                              |   mon，osd.1  |
                              |_______________|

```

#### 将node1添加为osd
##### node1执行
```
ssh node1
sudo mkdir /var/local/osd2
exit
```
##### admin执行
```
ceph-deploy osd prepare node1:/var/local/osd2
ceph-deploy osd activate node1:/var/local/osd2
```

##### 观察过程
```
ceph -w
```

#### 添加monitor集群
##### admin执行
````
 ceph-deploy mon add node2 node3
````

##### 检查状态
```
 ceph quorum_status --format json-pretty
```

## 步骤三，配置块设备
使用ceph RBD需要部署ceph-client，不能在Ceph存储集群相同的物理节点安装ceph-client节点。
### 创建主机
- 申请主机
- 配置ssh免密登录
- 修改/etc/hosts

### 检查操作系统版本
```
lsb_release -a
uname -r
```

### admin中配置ceph-client节点
```
ceph-deploy install ceph-client
sudo chmod +r /etc/ceph/ceph.client.admin.keyring
ceph-deploy admin ceph-client
```


## 参考资料
1. Ceph官方安装步骤：http://docs.ceph.org.cn/start/
2. Ceph日志目录：/var/log/ceph
