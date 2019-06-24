# RWX NFS volume

applications in different k8s namespace mount a nfs server.

## Create namespaces
```
kubectl create ns test1
kubectl create ns test2
```

## Create sc
```
# cat sc.yaml 
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  annotations:
    storageclass.kubesphere.io/supported_access_modes: '["ReadWriteOnce","ReadOnlyMany","ReadWriteMany"]'
  name: nfs-static
volumeBindingMode: Immediate
provisioner: kubernetes.io/nfs
```

## In test1 ns

### Create PV
```
# cat pv-test1.yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv1-test1
spec:
  capacity:
    storage: 5Gi
  volumeMode: Filesystem
  accessModes:
    - ReadWriteMany
  persistentVolumeReclaimPolicy: Recycle
  storageClassName: nfs-static
  nfs:
    path: /mnt/kube/pv-1
    server: 172.30.1.5
```

### Create PVC
```
# cat pvc-test1.yaml 
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: nfs-pvc
  namespace: test1
spec:
  accessModes:
    - ReadWriteMany
  volumeMode: Filesystem
  resources:
    requests:
      storage: 5Gi
  storageClassName: nfs-static
```

### Create deploy
```
# cat deploy-test1.yaml 
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx
  namespace: test1
spec:
  selector:
    matchLabels:
      app: nginx
  replicas: 1
  template:
    metadata:
      labels:
        app: nginx
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
          claimName: nfs-pvc
          readOnly: false

```

## In test2 ns

### Create PV
```
# cat pv-test2.yaml 
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv1-test2
spec:
  capacity:
    storage: 5Gi
  volumeMode: Filesystem
  accessModes:
    - ReadWriteMany
  persistentVolumeReclaimPolicy: Recycle
  storageClassName: nfs-static
  nfs:
    path: /mnt/kube/pv-1
    server: 172.30.1.5

```

### Create PVC
```
# cat pvc-test2.yaml 
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: nfs-pvc
  namespace: test2
spec:
  accessModes:
    - ReadWriteMany
  volumeMode: Filesystem
  resources:
    requests:
      storage: 5Gi
  storageClassName: nfs-static
```

### Create deploy
```
# cat deploy-test2.yaml 
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx
  namespace: test2
spec:
  selector:
    matchLabels:
      app: nginx
  replicas: 1
  template:
    metadata:
      labels:
        app: nginx
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
          claimName: nfs-pvc
          readOnly: false

```
