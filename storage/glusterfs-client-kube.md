# Glusterfs client install
Kubernetes使用glusterfs作动态数据卷分配来源，并已使用heketi管理端管理GlusterFS卷

## 准备材料
- glusterfs集群，并配置heketi集群管理工具
目前可供测试GLusterFS集群Heketi节点为：
ssh -P 10214 root@139.198.5.132
密码：Wx123456

- gluster-client-ubuntu16.04.tar
- kubernetes node ubuntu 16.04

## 配置Kubernetes
### 加载内核模块
```
modprobe dm_thin_pool
echo dm_thin_pool | sudo tee -a /etc/modules
```

## 安装gluster-client
```
# tar -xf gluster-client-ubuntu16.04.tar
# cd gluster-client-ubuntu16.04
# sudo install.sh
```

## 获取glusterfs集群信息
### 生成k8s对象glusterfs sc连接glusterfs所使用的密钥
在heketi主机操作
```
//进入heketi主机
cat /etc/heketi/heketi.json
{
  "_port_comment": "Heketi Server Port Number",
  "port": "8080",

  "_use_auth": "Enable JWT authorization. Please enable for deployment",
  "use_auth": false,

  "_jwt": "Private keys for access",
  "jwt": {
    "_admin": "Admin has access to all APIs",
    "admin": {
      "key": "123456"
    },
    "_user": "User only has access to /volumes endpoint",
    "user": {
      "key": "123456"
    }
  },

  "_glusterfs_comment": "GlusterFS Configuration",
  "glusterfs": {
    "_executor_comment": [
      "Execute plugin. Possible choices: mock, ssh",
      "mock: This setting is used for testing and development.",
      "      It will not send commands to any node.",
      "ssh:  This setting will notify Heketi to ssh to the nodes.",
      "      It will need the values in sshexec to be configured.",
      "kubernetes: Communicate with GlusterFS containers over",
      "            Kubernetes exec api."
    ],
    "executor": "ssh",

    "_sshexec_comment": "SSH username and private key file information",
    "sshexec": {
      "keyfile": "/root/.ssh/id_rsa",
      "user": "root"
    },

    "_kubeexec_comment": "Kubernetes configuration",
    "kubeexec": {
      "host" :"https://kubernetes.host:8443",
      "cert" : "/path/to/crt.file",
      "insecure": false,
      "user": "kubernetes username",
      "password": "password for kubernetes user",
      "namespace": "OpenShift project or Kubernetes namespace",
      "fstab": "Optional: Specify fstab file on node.  Default is /etc/fstab"
    },

    "_db_comment": "Database file name",
    "db": "/var/lib/heketi/heketi.db",
    "brick_max_size_gb" : 1024,
	"brick_min_size_gb" : 1,
	"max_bricks_per_volume" : 33,


    "_loglevel_comment": [
      "Set log level. Choices are:",
      "  none, critical, error, warning, info, debug",
      "Default is warning"
    ],
    "loglevel" : "debug"
  }
}

```


### 获取glusterfs集群id
```
# export HEKETI_CLI_SERVER=http://localhost:8080
# heketi-cli cluster list
Clusters:
d7a40738e7a6d1e6e284ba8190d3224c

```


## Kubernetes验证
### 创建secret
```
// from-literal=key内容来自heketi的/etc/heketi/heketi.json的jwt.admin.key字段
kubectl create secret generic heketi-secret   --type="kubernetes.io/glusterfs" --from-literal=key='XXX'   --namespace=default
```

### 创建storageclass
```
// clusterid:从heketi节点输入heketi-cli cluster list命令查询
// 其他参数从/etc/heketi/heketi.json里查看
# vim storageclass.yaml
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

### 创建PVC
```
# vim pvc.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  annotations:
    company: "qingcloud"
    project: "kubesphere"
  name: pvc-gluster-1
spec:
  accessModes:
    - ReadWriteMany
  storageClassName: gluster
  resources:
    requests:
      storage: 1Mi
```

### 创建deploy
```
# vim deploy.yaml
apiVersion: apps/v1 # for versions before 1.9.0 use apps/v1beta2
kind: Deployment
metadata:
  name: nginx-gluster
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nginx-gluster
  strategy:
    type: Recreate
  template:
    metadata:
      labels:
        app: nginx-gluster
    spec:
      containers:
      - image: nginx
        imagePullPolicy: IfNotPresent
        name: nginx
        volumeMounts:
        - mountPath: /root
          name: storage
          readOnly: false
      volumes:
      - name: storage
        persistentVolumeClaim:
          claimName: pvc-gluster-1

```

