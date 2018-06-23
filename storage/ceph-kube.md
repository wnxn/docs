# Ceph RBD in Kubernetes

本文旨在介绍RBD与Kubernetes结合使用
ceph-common/xenial-updates,now 10.2.9-0ubuntu0.16.04.1 
## Ceph介绍
- Ceph在Ceph存储集群之上提供对象存储（RadosGW），块存储（RadosBlockDevice，RBD）和文件存储（CephFS）三种功能的服务。由于仅有RBD支持Kubernetes的StorageClass，所以仅讨论RBD。

- Ceph存储集群包含Ceph Monitors和Ceph OSD两种类型守护进程。
	- Ceph Monitors：维护集群状态图表。
	- OSD: 检查自身和其他OSD状态，并报告给Monitors。使用CRUSH算法计算数据位置，不依赖中心化查询表。

- Ceph概念
	- 存储池：Pool，是存储对象的逻辑分区
	- image
	- PG：Placement Group 归置组
	- RBD: Rados Block Device
	- MON: Monitor节点
	- MDS: Ceph Metadata Server, 供CephFS使用
	- RADOS: Reliable Autonomic Distributed Object Store

- Ceph client访问volumes/images方法
	- KRBD： 内核驱动，内核态
	- librbd： 用户态，使用RBD-NBD (Network Block Device) tool, NBD Kernel module

## Kubernetes中使用Ceph
*. RBD(Rados Block Device) .*

- RBD可以被多个Pod同时以只读挂载(不会实时更新RBD卷的内容)
- RBD仅可被一个Pod以读写方式挂载

## [RBD as Volume](https://github.com/kubernetes/examples/tree/master/staging/volumes/rbd)
### 步骤
- 每个K8S Node安装ceph-common
```console
# sudo apt-get install ceph-common
```
sudo chmod +r /var/lib/ceph/bootstrap-osd/ceph.keyring

## RBD as StorageClass

无状态服务应只有一个Pod副本对应一个PVC，因为RBD会上锁
有状态服务可在Pod声明部分增加volumeClaimTemplate部分，自动创建多个PVC，所以有状态副本数可以是多个。

`StatefulSet资源定义文件`
```
apiVersion: apps/v1beta2
kind: StatefulSet
metadata:
  name: server
spec:
  replicas: 2
  serviceName: server-ss
  selector:
    matchLabels:
      role: server
  template:
    metadata:
      labels:
        role: server
    spec:
      containers:
      - name: server
        image: nginx
        volumeMounts:
          - mountPath: /var/lib/www/html
            name: mypvc
  volumeClaimTemplates:
  - metadata:
      name: mypvc
    spec:
      accessModes: [ "ReadWriteOnce" ]
      storageClassName: fast
      resources:
        requests:
          storage: 1Gi
```

`创建的PVC和PV`
``` 
root@i-7lkqcxsc:~/yaml1.10/sc1.8# kubectl get pvc
NAME             STATUS    VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
claim1           Bound     pvc-553fc235-4910-11e8-92e7-525423542ee2   2Gi        RWO            fast           18m
claim2           Bound     pvc-5e354ad1-48f2-11e8-92e7-525423542ee2   2Gi        RWO            fast           3h
mypvc-server-0   Bound     pvc-ce8c69d5-490e-11e8-92e7-525423542ee2   1Gi        RWO            fast           28m
mypvc-server-1   Bound     pvc-d116c76f-490e-11e8-92e7-525423542ee2   1Gi        RWO            fast           28m
mypvc-server-2   Bound     pvc-cc7ba3c4-490f-11e8-92e7-525423542ee2   1Gi        RWO            fast           21m
mypvc-server-3   Bound     pvc-cf3e2af7-490f-11e8-92e7-525423542ee2   1Gi        RWO            fast           21m
mypvc-server-4   Bound     pvc-d2460142-490f-11e8-92e7-525423542ee2   1Gi        RWO            fast           21m
root@i-7lkqcxsc:~/yaml1.10/sc1.8# kubectl get pv
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS    CLAIM                        STORAGECLASS             REASON    AGE
pvc-20a99119-46d9-11e8-92e7-525423542ee2   20Gi       RWO            Delete           Bound     kube-system/prometheus-pvc   qingcloud-storageclass             2d
pvc-553fc235-4910-11e8-92e7-525423542ee2   2Gi        RWO            Delete           Bound     default/claim1               fast                               18m
pvc-5e354ad1-48f2-11e8-92e7-525423542ee2   2Gi        RWO            Delete           Bound     default/claim2               fast                               3h
pvc-cc7ba3c4-490f-11e8-92e7-525423542ee2   1Gi        RWO            Delete           Bound     default/mypvc-server-2       fast                               21m
pvc-ce8c69d5-490e-11e8-92e7-525423542ee2   1Gi        RWO            Delete           Bound     default/mypvc-server-0       fast                               28m
pvc-cf3e2af7-490f-11e8-92e7-525423542ee2   1Gi        RWO            Delete           Bound     default/mypvc-server-3       fast                               21m
pvc-d116c76f-490e-11e8-92e7-525423542ee2   1Gi        RWO            Delete           Bound     default/mypvc-server-1       fast                               28m
pvc-d2460142-490f-11e8-92e7-525423542ee2   1Gi        RWO            Delete           Bound     default/mypvc-server-4       fast                               21m
```

## 常用命令
### pool操作
- 查看pool
```
# rados lspools
# ceph osd lspools
# rados df
```

- 创建pool
```
# ceph osd pool create pool1 64
```

- 调整pool副本
```
# ceph osd pool set pool1 size 2
```

- 删除pood
```
# ceph osd pool delete pool1
```

- 设置pool
```
# ceph osd pool set-quota pool1 max_objects 100           #最大100个对象
set-quota max_objects = 100 for pool pool1
# ceph osd pool set-quota pool1 max_bytes $((10 * 1024 * 1024 * 1024))    #容量大小最大为10G
set-quota max_bytes = 10737418240 for pool pool1 
```

- 重命名pool
```
# ceph osd pool rename pool1 pool2
```

### RBD操作
#### 创建image

- 在ceph-client节点上，创建image
```console
# rbd create foo --size 4096
```

- 在ceph-client节点上，把image映射为块设备
```console
# sudo rbd map foo --name client.admin
```

- 在ceph-client节点上，创建文件系统后就可以使用块设备了
```console
# sudo mkfs.ext4 -m0 /dev/rbd /rbd/foo
```

#### 生成RBD访问密钥
```
# ceph auth get-key client.admin
XXX
# echo -n "XXX" | base64
```
或
```
# grep key /etc/ceph/ceph.client.kube.keyring |awk '{printf "%s", $NF}'|base64
```

#### base64
```
# echo "XXX" | base64
# echo "XXX" | base64 -i // 忽略非字母
```

#### 查看RBD
```console
# rbd ls // 列出rbd（默认pool）的image
# rbd info foo
# rbd lock ls rbd/foo
# ll /var/log/ceph //ceph日志
```

#### k8s中controller-manager创建image命令
```
# rbd create cc2 --size 4096 --pool rbd --id admin -m 192.168.1.3 --key=AQDsQt1a2Jh5MxAA0zvyDYs0+wui0Jx0nqNSaw== --image-format=1 //k8s node中使用rbd命令行创建image
```

### 其他操作
#### node查看挂载卷命令
```
# fdisk -l
# df -lh
```

```
# kubectl get storageclass  --v=9 //查看api
# curl -X GET https://192.168.1.13:6443/api/v1 --cacert ca.crt // 查看api
# /etc/kubernetes/scheduler.conf
# :%s/\n//g //vim删除\n

```

## 参考资料
1. Ceph概念：http://docs.ceph.org.cn/architecture/
2. Ceph普通卷挂载：https://github.com/kubernetes/examples/tree/master/staging/volumes/rbd
3. Salesforce RBD in K8S v1.10： https://engineering.salesforce.com/mapping-kubernetes-ceph-volumes-the-rbd-nbd-way-21f7c4161f04
4. Ceph无法在Kubernetes使用问题讨论：https://github.com/ceph/ceph-container/issues/642
5. curl访问apiserver：https://kubernetes.io/docs/tasks/administer-cluster/access-cluster-api/