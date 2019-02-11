
## External Etcd in Master

### Swapoff

```
swapoff -a
free -m
```

### Pull images

```
root@i-5gysgjas:~# docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
k8s.gcr.io/etcd     3.2.24              3cab8e1b9802        3 months ago        220MB
k8s.gcr.io/pause    3.1                 da86e6ba6ca1        13 months ago       742kB
```

### kubeadm



```
cat << EOF > /etc/systemd/system/kubelet.service.d/20-etcd-service-manager.conf
[Service]
ExecStart=
ExecStart=/usr/bin/kubelet --address=127.0.0.1 --pod-manifest-path=/etc/kubernetes/manifests --allow-privileged=true
Restart=always
EOF
```

```
mv /etc/systemd/system/kubelet.service.d/20-etcd-service-manager.conf /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
```

```
systemctl daemon-reload
systemctl restart kubelet
systemctl status kubelet
```

### Etcd manifest

```
export ETCD0_IP=192.168.1.3
export ETCD1_IP=192.168.1.4
export ETCD2_IP=192.168.1.5
export ETCD_IP=$ETCD2_IP
```

```
cat << EOF > /etc/kubernetes/manifests/etcd.yaml
apiVersion: v1
kind: Pod
metadata:
  annotations:
    scheduler.alpha.kubernetes.io/critical-pod: ""
  creationTimestamp: null
  labels:
    component: etcd
    tier: control-plane
  name: etcd
  namespace: kube-system
spec:
  containers:
  - command:
    - etcd
    - --advertise-client-urls=http://${ETCD_IP}:2379
    - --initial-advertise-peer-urls=http://${ETCD_IP}:2380
    - --initial-cluster=infra0=http://${ETCD0_IP}:2380,infra1=http://${ETCD1_IP}:2380,infra2=http://${ETCD2_IP}:2380
    - --initial-cluster-state=new
    - --listen-client-urls=http://${ETCD_IP}:2379
    - --listen-peer-urls=http://${ETCD_IP}:2380
    - --name=infra2
    - --data-dir=/var/lib/etcd
    - --snapshot-count=10000
    image: k8s.gcr.io/etcd:3.2.24
    imagePullPolicy: IfNotPresent
    livenessProbe:
      exec:
        command:
        - /bin/sh
        - -ec
        - ETCDCTL_API=3 etcdctl --endpoints=http://[${ETCD_IP}]:2379 get foo
      failureThreshold: 8
      initialDelaySeconds: 15
      timeoutSeconds: 15
    name: etcd
    resources: {}
    volumeMounts:
    - mountPath: /var/lib/etcd
      name: etcd-data
    - mountPath: /etc/kubernetes/pki/etcd
      name: etcd-certs
  hostNetwork: true
  priorityClassName: system-cluster-critical
  volumes:
  - hostPath:
      path: /var/lib/etcd
      type: DirectoryOrCreate
    name: etcd-data
  - hostPath:
      path: /etc/kubernetes/pki/etcd
      type: DirectoryOrCreate
    name: etcd-certs
status: {}
EOF
```

### Check status

```
/ # ETCDCTL_API=3 etcdctl -w table --endpoints=http://192.168.1.55:2379,192.168.1.58:2379,192.168.1.56:2379 endpoint status
+---------------------------+------------------+---------+---------+-----------+-----------+------------+
|         ENDPOINT          |        ID        | VERSION | DB SIZE | IS LEADER | RAFT TERM | RAFT INDEX |
+---------------------------+------------------+---------+---------+-----------+-----------+------------+
| http://[192.168.1.3]:2379 | 288692ffb8a93e70 |  3.2.24 |   25 kB |      true |        57 |         15 |
|          192.168.1.4:2379 |  1667b822635af5d |  3.2.24 |   25 kB |     false |        57 |         15 |
|          192.168.1.5:2379 | c59bcebe80c5afdb |  3.2.24 |   25 kB |     false |        57 |         15 |
+---------------------------+------------------+---------+---------+-----------+-----------+------------+

```

```
#  etcdctl --endpoints=http://[192.168.1.3]:2379 cluster-health
member 1667b822635af5d is healthy: got healthy result from http://192.168.1.4:2379
member 288692ffb8a93e70 is healthy: got healthy result from http://192.168.1.3:2379
member c59bcebe80c5afdb is healthy: got healthy result from http://192.168.1.5:2379
cluster is healthy

```

## Etcd Binary

### Service Single Master Etcd
```
cat /lib/systemd/system/etcd.service
[Unit]
Description=etcd key-value store
Documentation=https://github.com/etcd-io/etcd
After=network.target

[Service]
Type=notify
ExecStart=/usr/bin/etcd     --data-dir=/var/lib/etcd
Restart=always
RestartSec=10s
LimitNOFILE=40000

[Install]
WantedBy=multi-user.target
```

### HA Etcd Master

> https://github.com/etcd-io/etcd/tree/master/contrib/systemd/etcd3-multinode

- Version: 3.2.24

### Download Etcd Binary
```
wget https://github.com/etcd-io/etcd/releases/download/v3.2.24/etcd-v3.2.24-linux-amd64.tar.gz
```

### Preparation
```
tar -xf etcd-v3.2.24-linux-amd64.tar.gz
cd etcd-v3.2.24-linux-amd64
cp etcd /usr/bin
cp etcdctl /usr/bin
```

```
mkdir /var/lib/etcd
ls /var/lib/etcd
rm -rf /var/lib/etcd/*
```

### Systemd Service File
```
export IP_1=192.168.1.3
export IP_2=192.168.1.4
export IP_3=192.168.1.5
export IP=$IP_3
```

```
cat > /tmp/etcd.service <<EOF
[Unit]
Description=etcd
Documentation=https://github.com/coreos/etcd
Conflicts=etcd.service
Conflicts=etcd2.service

[Service]
Type=notify
Restart=always
RestartSec=5s
LimitNOFILE=40000
TimeoutStartSec=0

ExecStart=/usr/bin/etcd \
    --advertise-client-urls http://${IP}:2379 \
    --initial-advertise-peer-urls http://${IP}:2380 \
    --initial-cluster my-etcd-1=http://${IP_1}:2380,my-etcd-2=http://${IP_2}:2380,my-etcd-3=http://${IP_3}:2380 \
    --initial-cluster-state new \
    --listen-client-urls http://${IP}:2379 \
    --listen-peer-urls http://${IP}:2380 \
    --name my-etcd-3 \
    --data-dir /var/lib/etcd \
    --snapshot-count=10000

[Install]
WantedBy=multi-user.target
EOF
sudo mv /tmp/etcd.service /etc/systemd/system/etcd.service
```

```
sudo systemctl daemon-reload
sudo systemctl enable etcd
sudo systemctl start etcd
sudo systemctl status etcd
```

### Check
```
/ # ETCDCTL_API=3 etcdctl -w table --endpoints=http://[192.168.1.3]:2379,192.168.1.4:2379,192.168.1.5:2379 endpoint status
+---------------------------+------------------+---------+---------+-----------+-----------+------------+
|         ENDPOINT          |        ID        | VERSION | DB SIZE | IS LEADER | RAFT TERM | RAFT INDEX |
+---------------------------+------------------+---------+---------+-----------+-----------+------------+
| http://[192.168.1.3]:2379 | 288692ffb8a93e70 |  3.2.24 |   25 kB |      true |        57 |         15 |
|          192.168.1.4:2379 |  1667b822635af5d |  3.2.24 |   25 kB |     false |        57 |         15 |
|          192.168.1.5:2379 | c59bcebe80c5afdb |  3.2.24 |   25 kB |     false |        57 |         15 |
+---------------------------+------------------+---------+---------+-----------+-----------+------------+

```

```
ETCDCTL_API=3 etcdctl -w table --endpoints=http://i-b75jnuz7:2379,i-hfpo2o8l:2379,i-hscdn8ry:2379 endpoint status
```

```
#  etcdctl --endpoints=http://[192.168.1.3]:2379 cluster-health
member 1667b822635af5d is healthy: got healthy result from http://192.168.1.4:2379
member 288692ffb8a93e70 is healthy: got healthy result from http://192.168.1.3:2379
member c59bcebe80c5afdb is healthy: got healthy result from http://192.168.1.5:2379
cluster is healthy

```

```
ETCDCTL_API=3 etcdctl --endpoints=http://[192.168.1.24]:2379 put /wx/test test1
```

```
# ETCDCTL_API=3 etcdctl --endpoints=http://[192.168.1.24]:2379 get /wx/test
/wx/test
test1
```