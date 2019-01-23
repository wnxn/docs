# 跨区迁移 Flex volume 存储卷

跨区迁移前请先将重要数据备份，文中重要的字段用 "<>" 表明。

## 在A区集群 1

- 动态创建 Flex Volume PVC
- 将 PVC 挂载至工作负载，写入数据
- 将 PVC 与工作负载解绑
- 编辑 PV 回收卷方式为 Retain
- 删除 PVC 和 PV

### 创建 PVC

- 编写 PVC YAML 定义文件
```
# cat pvc.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-cluster1
  namespace: default
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
  storageClassName: qingcloud-storageclass
```

- 创建 PVC
```
kubectl create -f pvc.yaml
```

- 等待 PVC 创建成功
```
# kubectl get pvc
NAME           STATUS    VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS             AGE
pvc-cluster1   Bound     pvc-2cf1a4a3-1eb1-11e9-95bd-5254a6631c8c   10Gi       RWO            qingcloud-storageclass   21s
```

```
# kubectl get pv pvc-2cf1a4a3-1eb1-11e9-95bd-5254a6631c8c
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS    CLAIM                  STORAGECLASS             REASON    AGE
pvc-2cf1a4a3-1eb1-11e9-95bd-5254a6631c8c   10Gi       RWO            Delete           Bound     default/pvc-cluster1   qingcloud-storageclass             2m

```

### 创建 Deployment， 挂载 PVC
```
# cat deploy.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx
spec:
  selector:
    matchLabels:
      app: nginx
      tier: csi-qingcloud
  replicas: 1
  template:
    metadata:
      labels:
        app: nginx
        tier: csi-qingcloud
    spec:
      containers:
      - name: nginx
        image: nginx
        volumeMounts:
        - mountPath: /mnt
          name: mypvc
      volumes:
      - name: mypvc
        persistentVolumeClaim:
          claimName: pvc-cluster1
          readOnly: false

```

```
# kubectl get po
NAME                     READY     STATUS    RESTARTS   AGE
nginx-67b6fdd64f-zz8dk   1/1       Running   0          52s
```

### 在 PVC 内写入数据

```
# kubectl exec -ti nginx-67b6fdd64f-zz8dk /bin/bash
# cd /mnt
# date >> tmp
# echo cluster1 >> tmp
# cat tmp
Mon Jan 21 12:44:24 UTC 2019
cluster1
```

### 解绑 PVC
```
# kubectl delete -f deploy.yaml 
deployment.apps "nginx" deleted
```

### 编辑 PV 回收卷方式为 Retain
```
# kubectl edit pv pvc-2cf1a4a3-1eb1-11e9-95bd-5254a6631c8c
apiVersion: v1
kind: PersistentVolume
metadata:
  ...
  name: pvc-2cf1a4a3-1eb1-11e9-95bd-5254a6631c8c
  ...
spec:
  accessModes:
  - ReadWriteOnce
  capacity:
    storage: 10Gi
  claimRef:
    apiVersion: v1
    kind: PersistentVolumeClaim
    name: pvc-cluster1
    namespace: default
    resourceVersion: "4856"
    uid: 77b34fe0-1d79-11e9-95bd-5254a6631c8c
  flexVolume:
    driver: qingcloud/flex-volume
    fsType: ext4
    options:
      volumeID: vol-ttwtvfeb
  persistentVolumeReclaimPolicy: <Retain>
  storageClassName: qingcloud-storageclass
  volumeMode: Filesystem
status:
  phase: Bound
```

### 删除 PVC 和 PV
```
# kubectl delete pvc pvc-cluster1
persistentvolumeclaim "pvc-cluster1" deleted
# kubectl delete pv pvc-2cf1a4a3-1eb1-11e9-95bd-5254a6631c8c
persistentvolume "pvc-2cf1a4a3-1eb1-11e9-95bd-5254a6631c8c" deleted
```

## 硬盘迁移

- 在 QingCloud Console 内，1. A 区硬盘创建备份，2. 将 A 区硬盘迁移至 B 区，可参考跨区复制备份：https://docs.qingcloud.com/product/storage/volume/performance_volume/ ，3. 在 B 区从备份创建硬盘：https://docs.qingcloud.com/product/storage/snapshot#%E5%A4%87%E4%BB%BD%E5%AF%BC%E5%87%BA


1. A 区创建硬盘（ID：vol-ttwtvfeb，Name：pvc-2cf1a4a3-1eb1-11e9-95bd-5254a6631c8c）的备份（ID：ss-7556enk7，Name：snap-vol-ttwtvfeb）,这一步可在 A 区集群 1 内 PVC 从 Workload 解绑后执行。
2. A 区备份处选中备份，选择跨区复制备份到 B 区
3. B 区备份处，选中备份（ID：ss-7556enk7，Name：snap-vol-ttwtvfeb），右单击创建硬盘（硬盘类型依据 B 区 Kubernetes 集群主机类型选定）（ID：vol-bf56v08y，Name：pvc-2cf1a4a3-1eb1-11e9-95bd-5254a6631c8c）

## 在 B 区集群 2

- 采用静态创建 PVC 方式，首先创建 PV，再创建 PVC，将 PVC 与 PV 绑定
- 测试新的 PVC 是否可用，将 PVC 挂载至工作负载，检查 PVC 内数据

### 创建 PV
```
$ vi pv.yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  annotations:
    Provisioner_Id: qingcloud/volume-provisioner
    kubernetes.io/createdby: qingcloud-volume-provisioner
    pv.kubernetes.io/provisioned-by: qingcloud/volume-provisioner
  name: <pvc-2cf1a4a3-1eb1-11e9-95bd-5254a6631c8c>
spec:
  capacity:
    storage: 10Gi
  volumeMode: Filesystem
  accessModes:
  - ReadWriteOnce
  persistentVolumeReclaimPolicy: Delete
  storageClassName: qingcloud-storageclass
  flexVolume:
    driver: qingcloud/flex-volume
    fsType: ext4
    options:
      volumeID: <vol-bf56v08y>
```

```
kubectl create -f pv.yaml
```

### 创建 PVC

```
# vi pvc.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-cluster1
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
  storageClassName: qingcloud-storageclass
  volumeMode: Filesystem
  volumeName: <pvc-2cf1a4a3-1eb1-11e9-95bd-5254a6631c8c>
```

```
kubectl create -f pvc.yaml
```

### 检查 PVC
```
# kubectl get pvc
NAME           STATUS    VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS             AGE
pvc-cluster1   Bound     pvc-2cf1a4a3-1eb1-11e9-95bd-5254a6631c8c   10Gi       RWO            qingcloud-storageclass   10m
```

### 挂载 PVC 至工作负载

```
# cat deploy.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx
spec:
  selector:
    matchLabels:
      app: nginx
      tier: csi-qingcloud
  replicas: 1
  template:
    metadata:
      labels:
        app: nginx
        tier: csi-qingcloud
    spec:
      containers:
      - name: nginx
        image: nginx
        volumeMounts:
        - mountPath: /mnt
          name: mypvc
      volumes:
      - name: mypvc
        persistentVolumeClaim:
          claimName: pvc-cluster1
          readOnly: false
```

```
kubectl create -f deploy.yaml
```

### 检查

```
# kubectl get po
kNAME                     READY     STATUS    RESTARTS   AGE
nginx-67b6fdd64f-7xlf5   1/1       Running   0          1m
# kubectl exec -ti nginx-67b6fdd64f-7xlf5  /bin/bash
# cat /mnt/tmp
Mon Jan 21 12:44:24 UTC 2019
cluster1
```