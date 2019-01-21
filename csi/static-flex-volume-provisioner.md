# Flex volume 存储卷迁移

## 在集群 1

- 动态创建 Flex Volume PVC
- 将 PVC 挂载至工作负载，写入数据
- 将 PVC 与工作负载解绑
- 编辑 PV 回收卷方式为 Retain
- 删除 PVC 和 PV

### 创建 PVC
```
# cat pvc-cluster1.yaml
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

```
kubectl create -f pvc-cluster1.yaml
```

### 检查 PVC
```
# kubectl get pvc
NAME           STATUS    VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS             AGE
pvc-cluster1   Bound     pvc-77b34fe0-1d79-11e9-95bd-5254a6631c8c   10Gi       RWO            qingcloud-storageclass   21s
```

```
# kubectl get pvc pvc-cluster1 -oyaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  annotations:
    control-plane.alpha.kubernetes.io/leader: '{"holderIdentity":"abaa88ca-1d76-11e9-9e52-5254a6631c8c","leaseDurationSeconds":15,"acquireTime":"2019-01-21T12:38:37Z","renewTime":"2019-01-21T12:38:51Z","leaderTransitions":0}'
    pv.kubernetes.io/bind-completed: "yes"
    pv.kubernetes.io/bound-by-controller: "yes"
    volume.beta.kubernetes.io/storage-provisioner: qingcloud/volume-provisioner
  creationTimestamp: 2019-01-21T12:38:34Z
  finalizers:
  - kubernetes.io/pvc-protection
  name: pvc-cluster1
  namespace: default
  resourceVersion: "4916"
  selfLink: /api/v1/namespaces/default/persistentvolumeclaims/pvc-cluster1
  uid: 77b34fe0-1d79-11e9-95bd-5254a6631c8c
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
  storageClassName: qingcloud-storageclass
  volumeMode: Filesystem
  volumeName: pvc-77b34fe0-1d79-11e9-95bd-5254a6631c8c
status:
  accessModes:
  - ReadWriteOnce
  capacity:
    storage: 10Gi
  phase: Bound
```

### 检查 PV

```
# kubectl get pv pvc-77b34fe0-1d79-11e9-95bd-5254a6631c8c -oyaml
apiVersion: v1
kind: PersistentVolume
metadata:
  annotations:
    Provisioner_Id: qingcloud/volume-provisioner
    kubernetes.io/createdby: qingcloud-volume-provisioner
    pv.kubernetes.io/provisioned-by: qingcloud/volume-provisioner
  creationTimestamp: 2019-01-21T12:38:50Z
  finalizers:
  - kubernetes.io/pv-protection
  name: pvc-77b34fe0-1d79-11e9-95bd-5254a6631c8c
  resourceVersion: "4912"
  selfLink: /api/v1/persistentvolumes/pvc-77b34fe0-1d79-11e9-95bd-5254a6631c8c
  uid: 80dbcac0-1d79-11e9-95bd-5254a6631c8c
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
  persistentVolumeReclaimPolicy: Delete
  storageClassName: qingcloud-storageclass
  volumeMode: Filesystem
status:
  phase: Bound
```

### 将 PVC 挂载至工作负载
```
# cat deploy-nginx.yaml
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
nginx-67b6fdd64f-k4js6   1/1       Running   0          1m
```

### 在 PVC 内写入数据

```
# kubectl exec -ti nginx-67b6fdd64f-k4js6 /bin/bash
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
# kubectl edit pv pvc-77b34fe0-1d79-11e9-95bd-5254a6631c8c
apiVersion: v1
kind: PersistentVolume
metadata:
  ...
  name: pvc-77b34fe0-1d79-11e9-95bd-5254a6631c8c
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
  persistentVolumeReclaimPolicy: Retain
  storageClassName: qingcloud-storageclass
  volumeMode: Filesystem
status:
  phase: Bound
```

### 删除 PVC 和 PV
```
# kubectl delete pvc pvc-cluster1
persistentvolumeclaim "pvc-cluster1" deleted
# kubectl delete pv pvc-77b34fe0-1d79-11e9-95bd-5254a6631c8c
persistentvolume "pvc-77b34fe0-1d79-11e9-95bd-5254a6631c8c" deleted
```

## 在集群 2

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
  name: pvc-77b34fe0-1d79-11e9-95bd-5254a6631c8c
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
      volumeID: vol-ttwtvfeb
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
  volumeName: pvc-77b34fe0-1d79-11e9-95bd-5254a6631c8c
```

```
kubectl create -f pvc.yaml
```

### 检查 PVC
```
# kubectl get pvc
NAME           STATUS    VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS             AGE
pvc-cluster1   Bound     pvc-77b34fe0-1d79-11e9-95bd-5254a6631c8c   10Gi       RWO            qingcloud-storageclass   10m
```

### 挂载 PVC 至工作负载

```
# cat deploy-nginx.yaml
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
kubectl create -f deploy-nginx.yaml
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

### 删除 PVC
- 将 PVC 与 Workload 解绑
- 删除 PVC 将会动态删除 PV 和 QingCloud 云平台块存储硬盘