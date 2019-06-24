## Preparation
- Install NFS client

> Install NFS client on Kubernetes nodes
```
$ sudo apt-get update
$ sudo apt-get install nfs-common
```

- Setup a NFS server

## Static Volume Provisioning

- Create directory in NFS server
```
$ mkdir -p /home/pv-nfs
```

- Create StorageClass
```
$ cat sc.yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: nfs-static
provisioner: eample.com/nfs
reclaimPolicy: Delete
volumeBindingMode: Immediate

$ kubectl create -f sc.yaml
```

- Create PV
```
$ cat pv.yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: nfs
spec:
  capacity:
    storage: 5Gi
  volumeMode: Filesystem
  accessModes:
    - ReadWriteMany
  storageClassName: nfs-static
  persistentVolumeReclaimPolicy: Recycle
  nfs:
    # FIXME: use the right IP
    server: 192.168.1.5
    path: "/home/pv-nfs"

$ kubectl create -f pv.yaml
```

- Create PVC
```
$ cat pvc.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: nfs
spec:
  accessModes:
    - ReadWriteMany
  volumeMode: Filesystem
  storageClassName: nfs-static
  resources:
    requests:
      storage: 3Gi

$ kubectl create -f pvc.yaml
```

- Mount PVC
```
$ cat rc.yaml
apiVersion: v1
kind: ReplicationController
metadata:
  name: nfs-web
spec:
  replicas: 2
  selector:
    role: web-frontend
  template:
    metadata:
      labels:
        role: web-frontend
    spec:
      containers:
      - name: web
        image: nginx
        ports:
          - name: web
            containerPort: 80
        volumeMounts:
            # name must match the volume name below
            - name: nfs
              mountPath: "/mnt"
      volumes:
      - name: nfs
        persistentVolumeClaim:
          claimName: nfs

$ kubectl create -f rc.yaml
```

## Dynamic Volume Provisioning
### Deploy NFS-Client Provisioner
- Create RBAC
```
$ cat rbac.yaml
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: nfs-client-provisioner-runner
rules:
  - apiGroups: [""]
    resources: ["persistentvolumes"]
    verbs: ["get", "list", "watch", "create", "delete"]
  - apiGroups: [""]
    resources: ["persistentvolumeclaims"]
    verbs: ["get", "list", "watch", "update"]
  - apiGroups: ["storage.k8s.io"]
    resources: ["storageclasses"]
    verbs: ["get", "list", "watch"]
  - apiGroups: [""]
    resources: ["events"]
    verbs: ["create", "update", "patch"]
---
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: run-nfs-client-provisioner
subjects:
  - kind: ServiceAccount
    name: nfs-client-provisioner
    namespace: kube-system
roleRef:
  kind: ClusterRole
  name: nfs-client-provisioner-runner
  apiGroup: rbac.authorization.k8s.io
---
kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: leader-locking-nfs-client-provisioner
rules:
  - apiGroups: [""]
    resources: ["endpoints"]
    verbs: ["get", "list", "watch", "create", "update", "patch"]
---
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: leader-locking-nfs-client-provisioner
subjects:
  - kind: ServiceAccount
    name: nfs-client-provisioner
    # replace with namespace where provisioner is deployed
    namespace: kube-system
roleRef:
  kind: Role
  name: leader-locking-nfs-client-provisioner
  apiGroup: rbac.authorization.k8s.io
```

```
$ NAMESPACE=kube-system
$ sed -i'' "s/namespace:.*/namespace: $NAMESPACE/g" ./rbac.yaml
$ kubectl create -f rbac.yaml
```
- Create Directory in NFS Server
```
$ mkdir -p /home/nfs
```

- Create NFS-Client Provisioner
```
$ cat deployment.yaml
kind: Deployment
apiVersion: extensions/v1beta1
metadata:
  name: nfs-client-provisioner
spec:
  replicas: 1
  strategy:
    type: Recreate
  template:
    metadata:
      labels:
        app: nfs-client-provisioner
    spec:
      serviceAccountName: nfs-client-provisioner
      containers:
        - name: nfs-client-provisioner
          image: quay.io/external_storage/nfs-client-provisioner:latest
          volumeMounts:
            - name: nfs-client-root
              mountPath: /persistentvolumes
          env:
            - name: PROVISIONER_NAME
              value: fuseim.pri/ifs
            - name: NFS_SERVER
              value: 192.168.1.5
            - name: NFS_PATH
              value: /home/nfs
      volumes:
        - name: nfs-client-root
          nfs:
            server: 192.168.1.5
            path: /home/nfs
```

```
$ kubectl create -f deployment.yaml
```

### Usage
- Create StorageClass
```
$ cat sc.yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: managed-nfs-storage
provisioner: fuseim.pri/ifs # or choose another name, must match deployment's env PROVISIONER_NAME'
parameters:
  archiveOnDelete: "false"

$ kubectl create -f sc.yaml
```

- Create PVC
```
$ cat pvc.yaml
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: test-claim
  annotations:
    volume.beta.kubernetes.io/storage-class: "managed-nfs-storage"
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 1Mi

$ kubectl create -f pvc.yaml
```

- Check Volume
```
$ kubectl get pvc
NAME         STATUS    VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS          AGE
test-claim   Bound     pvc-e8539192-bd70-11e8-8a65-52540f18a8e9   1Mi        RWX            managed-nfs-storage   10s

$ kubectl get pv 
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS    CLAIM                    STORAGECLASS          REASON    AGE
pvc-e8539192-bd70-11e8-8a65-52540f18a8e9   1Mi        RWX            Delete           Bound     kube-system/test-claim   managed-nfs-storage             36s
```

- Check NFS Server
```
root@i-q9x7me8m:/home# ls
lost+found  nfs  pv-nfs  tmp
root@i-q9x7me8m:/home# ls -la nfs
total 16
drwxr-xr-x 4 root root 4096 Sep 21 15:35 .
drwxr-xr-x 5 root root 4096 Sep 21 15:07 ..
drwxrwxrwx 2 root root 4096 Sep 21 15:35 kube-system-test-claim-pvc-e8539192-bd70-11e8-8a65-52540f18a8e9
```

## Reference

- [Install NFS Server and Client](https://www.digitalocean.com/community/tutorials/how-to-set-up-an-nfs-mount-on-ubuntu-16-04)
- [Dynamic Provision NFS Volume](https://github.com/kubernetes-incubator/external-storage/tree/master/nfs-client)