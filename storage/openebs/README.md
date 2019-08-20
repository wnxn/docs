## 安装
> https://docs.openebs.io/#font-size-6-quickstart-font
```
$ kubectl apply -f openebs-operator-1.1.0.yaml
$ kubectl apply -f sc.yaml
```

## 检查
```
# kubectl get pods -n openebs -l openebs.io/version=1.1.0
NAME                                           READY   STATUS    RESTARTS   AGE
maya-apiserver-78c966c446-c9df4                1/1     Running   0          6m13s
openebs-admission-server-66f46564f5-n6vfm      1/1     Running   0          6m12s
openebs-localpv-provisioner-698496cf9b-5n84w   1/1     Running   0          5m32s
openebs-ndm-dw8dw                              1/1     Running   0          4m57s
openebs-ndm-operator-7fb4894546-fbczj          1/1     Running   0          6m2s
openebs-ndm-x25jk                              1/1     Running   0          6m2s
openebs-provisioner-7f9c99cf9-lzghf            1/1     Running   0          6m13s
openebs-snapshot-operator-79f7d56c7d-hpwdx     2/2     Running   0          6m2s
```

```
$ kubectl get sc
NAME                        PROVISIONER                                                AGE
openebs-local               openebs.io/local                                           69m
openebs-snapshot-promoter   volumesnapshot.external-storage.k8s.io/snapshot-promoter   19d
```

> Local Volume 会在调度 pod 的 node 上 `/var/openebs/local` 文件夹内创建文件夹
> 由于是静态分配存储卷，所以当 pod 调度后 pvc 才会 bound。

## 使用
### 创建 PVC
```
$ kubectl create -f pvc.yaml
```

### 创建 Deploy
```
$ kubectl create -f deploy.yaml
```

### 检查

1. 检查 Pod
```
# kubectl get po -o wide
NAME                       READY   STATUS    RESTARTS   AGE   IP           NODE         NOMINATED NODE   READINESS GATES
percona-5b8d447558-9cwst   1/1     Running   0          69m   10.10.3.34   i-yi12sl8d   <none>           <none>
```

2. 检查 PVC
```
# kubectl get pvc
NAME          STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS    AGE
openebs-pvc   Bound    pvc-12f2339b-c31e-11e9-a026-52549938a379   5G         RWO            openebs-local   71m
```

3. 去 Pod 所在主机 `i-yi12sl8d` 上看文件夹
```
root@i-yi12sl8d:~# ls /var/openebs/local/pvc-12f2339b-c31e-11e9-a026-52549938a379/
auto.cnf    ca.pem           client-key.pem  ibdata1      ib_logfile1  mysql       mysql.sock.lock     private_key.pem  server-cert.pem  sys
ca-key.pem  client-cert.pem  ib_buffer_pool  ib_logfile0  ibtmp1       mysql.sock  performance_schema  public_key.pem   server-key.pem   xb_doublewrite
```