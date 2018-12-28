# Install External Kubernetes with Etcd App

## Prepare

### Create Etcd App

```
./etcdctl --endpoints http://192.168.1.25:2379,http://192.168.1.26:2379,http://192.168.1.27:2379 cluster-health
```

### Create LB

- Create LB in QingCloud console
- Add TCP rule and firewall rule

## Install Control Plane

### Setup first control plane

```
swapoff -a
```

#### Create kubeadm config file

```
export LB_IP=192.168.1.251
export LB_NAME=apiserver-lb
export ETCD0_IP=
export ETCD1_IP=
export ETCD2_IP=
```

```
$ cat << EOF > ~/kubeadm-config.yaml
apiVersion: kubeadm.k8s.io/v1alpha3
kind: InitConfiguration
bootstrapTokens:
- ttl: "0"
nodeRegistration:
  kubeletExtraArgs:
    cgroup-driver: "cgroupfs"
    max-pods: "60"
    fail-swap-on: "true"
---
apiVersion: kubeadm.k8s.io/v1alpha3
kind: ClusterConfiguration
etcd:
    external:
        endpoints:
        - http://${ETCD0_IP}:2379
        - http://${ETCD1_IP}:2379
        - http://${ETCD2_IP}:2379
networking:
  dnsDomain: cluster.local
  podSubnet: 10.10.0.0/16
  serviceSubnet: 10.96.0.0/16
kubernetesVersion: "v1.12.4"
controlPlaneEndpoint: "${LB_IP}:6443"
apiServerCertSANs:
- "${LB_NAME}"
imageRepository: "k8s.gcr.io"
unifiedControlPlaneImage: "gcr.io/google_containers/hyperkube-amd64:v1.12.4"
---
apiVersion: kubeproxy.config.k8s.io/v1alpha1
kind: KubeProxyConfiguration
mode: "ipvs"
EOF
```

#### Run Kubeadm init

```
kubeadm init --config kubeadm-config.yaml
```