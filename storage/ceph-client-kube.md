# Ceph client离线安装

在Kubernetes node上安装ceph rbd客户端

## 准备材料

- Ubuntu16.04操作系统
- ceph-client-ubuntu16.04.tar安装包
- ceph rbd存储集群配置ceph.client.admin.keyring
- ceph rbd存储集群配置ceph.conf

## 安装ceph-client

1. 解压ceph-client-ubuntu16.04.tar安装包

2. 执行install.sh脚本

## 配置ceph-client

1. 将ceph.client.admin.keyring拷贝至/etc/ceph下

2. 将ceph.conf拷贝至/etc/ceph下

## 主机命令行验证

1. 列出rbd image
```
# sudo rbd ls
foo
```

2. 查看image信息
```
# sudo rbd info foo
rbd image 'foo':
    size 4096 MB in 1024 objects
    order 22 (4096 kB objects)
    block_name_prefix: rbd_data.102a643c9869
    format: 2
    // format可以选择1
    // format为2时，请特别关注image feature，
    // 如果map timeout失败可能是操作系统内核不支持，
    // 可用如下命令修改imagefeatures
    // rbd feature disable foo exclusive-lock object-map fast-diff deep-flatten
    features: layering, exclusive-lock, object-map, fast-diff, deep-flatten 
    flags: 
    create_timestamp: Thu Jun 14 04:10:06 2018
```

3. 将rbd image映射到foo
```
# sudo rbd map foo --name client.admin
```

4. 格式化
```
# sudo mkfs.ext4 -m0 /dev/rbd/rbd/foo
```

5. 挂载rbd image
```
mount /dev/rbd0 /mnt
```

6. 卸载rbd image
```
umount /dev/rbd0
```

## Kubernetes验证

1. 创建Secret对象
```
# ceph auth get-key client.admin
XXX

# echo -n "XXX" | base64

# vim ceph-secret.yaml
apiVersion: v1
kind: Secret
metadata:
  name: ceph-secret-admin
type: "kubernetes.io/rbd"
data:
#Please note this value is base64 encoded.
  key: XXX

# vim ceph-secret.yaml
apiVersion: v1
kind: Secret
metadata:
  name: ceph-secret-user
type: "kubernetes.io/rbd"
data:
#Please note this value is base64 encoded.
  key: XXX
```

2. 创建StorageClass对象
```
# vim storageclass.yaml
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: fast
  annotations:
    company: "qingcloud"
    project: "kubesphere"
provisioner: kubernetes.io/rbd
parameters:
  monitors: 192.168.0.7:6789 //按情况修改参数
  adminId: admin
  adminSecretName: ceph-secret-admin
  adminSecretNamespace: default
  pool: rbd
  userId: admin
  userSecretName: ceph-secret-user
  fsType: ext4
  imageFormat: "1" 
allowVolumeExpansion: true

```

3.  创建pvc对象
```
# vim pvc.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  annotations:
    company: "qingcloud"
    project: "kubesphere"
  name: claim-rox
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: fast
  resources:
    requests:
      storage: 3Mi
```

4.  创建deploy挂载pvc
```
# vim deploy.yaml
apiVersion: apps/v1 # for versions before 1.9.0 use apps/v1beta2
kind: Deployment
metadata:
  name: server-ceph
spec:
  replicas: 1
  selector:
    matchLabels:
      app: server-ceph
  strategy:
    type: Recreate
  template:
    metadata:
      labels:
        app: server-ceph
    spec:
      containers:
      - image: nginx
        imagePullPolicy: IfNotPresent
        name: server-non
        volumeMounts:
        - mountPath: /root
          name: storage
          readOnly: true
      volumes:
      - name: storage
        persistentVolumeClaim:
          claimName: claim-rox
```