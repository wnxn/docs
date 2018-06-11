# glusterfs-kube
Kubernetes使用glusterfs作动态数据卷分配来源，并已使用heketi管理端管理GlusterFS卷

## 配置Kubernetes
### 加载内核模块
```
modprobe dm_thin_pool
echo dm_thin_pool | sudo tee -a /etc/modules
```

### 安装glusterfs-client
安装方法1.
```
apt-get update
apt install glusterfs-common/xenial
apt-get install glusterfs-client/xenial
```
安装方法2.
```
wget -O - http://download.gluster.org/pub/gluster/glusterfs/3.8/LATEST/rsa.pub | sudo apt-key add - && \
echo deb http://download.gluster.org/pub/gluster/glusterfs/3.8/LATEST/Debian/jessie/apt jessie main | sudo tee /etc/apt/sources.list.d/gluster.list && \
apt-get update && sudo apt install -y glusterfs-client
```
缺少模块时使用
```
apt install attr
```

安装方法3.
解压gluster-client-ubuntu16.04.tar
```
tar -xf gluster-client-ubuntu16.04.tar //解压
cd ./gluster-client-ubuntu16.04 //进入文件夹
./install.sh // 安装
```

root用户下需要配置，以使用kubectl
```
export KUBECONFIG=/etc/kubernetes/admin.conf
```

配置glusterfs sc连接heketi所使用的密钥
```
kubectl create secret generic heketi-secret   --type="kubernetes.io/glusterfs" --from-literal=key='123456'   --namespace=default
```

## 创建StorageClass
clusterid:从heketi节点输入heketi-cli cluster list命令查询
```
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: gluster
provisioner: kubernetes.io/glusterfs
parameters:
  resturl: "http://192.168.1.19:8080"
  clusterid: "868755d558cb7326c6d8d6ce3927a493"
  restauthenabled: "true"
  restuser: "admin"
  secretNamespace: "default"
  secretName: "heketi-secret"
  gidMin: "40000"
  gidMax: "50000"
  volumetype: "replicate:2"
```

## 使用gluster
- 查看gluster数据卷的用量详情
```
# gluster volume status vol_cdb437ca8493f8f0da86b3adeee83b33  detail
```

- 查看gluster volume列表
```
# gluster volume list
```

## 制作离线客户端安装包
### ubuntu
```
// apt 安装包下载至此目录下
# ls /var/cache/apt/archives
// dpkg 使用deb安装包
# dpkg -i XXX.deb
```

## 参考资料
1. IBM glusterfs配置：https://www.ibm.com/support/knowledgecenter/en/SSBS6K_2.1.0/installing/storage_settings.html
2. GlusterFS与Heketi分开部署：https://blog.csdn.net/liukuan73/article/details/78477520
3. Kubernetes动态分配Glusterfs举例，例子老了：https://github.com/gluster/gluster-kubernetes/blob/master/docs/examples/hello_world/README.md