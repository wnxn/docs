# How to install Kubernetes quickly by kubeadm config
## Kubeadm config (Master)

```
apiVersion: kubeadm.k8s.io/v1alpha3
kind: InitConfiguration
bootstrapTokens:
- ttl: "0"
nodeRegistration:
  kubeletExtraArgs:
    cgroup-driver: "cgroupfs"
    max-pods: "73"
    fail-swap-on: "true"
    root-dir: "/var/lib/kubelet"
    allow-privileged: "true"
    feature-gates: "KubeletPluginsWatcher=false,CSINodeInfo=false,CSIDriverRegistry=false"
---
apiVersion: kubeadm.k8s.io/v1alpha3
kind: ClusterConfiguration
etcd:
  local:
    extraArgs:
      name: "i-7viz6hc3"
      listen-client-urls: "https://127.0.0.1:2379,https://192.168.0.2:2379"
      advertise-client-urls: "https://192.168.0.2:2379"
      listen-peer-urls: "https://192.168.0.2:2380"
      initial-advertise-peer-urls: "https://192.168.0.2:2380"
      initial-cluster: "i-7viz6hc3=https://192.168.0.2:2380"
    serverCertSANs:
      - i-7viz6hc3
      - 192.168.0.2
    peerCertSANs:
      - i-7viz6hc3
      - 192.168.0.2
networking:
  dnsDomain: "cluster.local"
  podSubnet: "10.10.0.0/16"
  serviceSubnet: "10.96.0.0/16"
kubernetesVersion: "v1.12.4"
controlPlaneEndpoint: "192.168.0.2:6443"
imageRepository: "k8s.gcr.io"
unifiedControlPlaneImage: "gcr.io/google_containers/hyperkube-amd64:v1.12.4"
apiServerExtraArgs:
  feature-gates: "KubeletPluginsWatcher=false,CSINodeInfo=false,CSIDriverRegistry=false"
controllerManagerExtraArgs:
  feature-gates: "KubeletPluginsWatcher=false,CSINodeInfo=false,CSIDriverRegistry=false"
schedulerExtraArgs:
  feature-gates: "KubeletPluginsWatcher=false,CSINodeInfo=false,CSIDriverRegistry=false"
certificatesDir: "/etc/kubernetes/pki"
---
apiVersion: kubeproxy.config.k8s.io/v1alpha1
kind: KubeProxyConfiguration
mode: "ipvs"
```

## Init (Master)

```
kubeadm init --config kubeadm-config.yaml
```

## KubeConfig (Master)
```
	mkdir -p $HOME/.kube
	sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
	sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

## Install Network plugin (Master)

### Calico

- rbac
    ```
    kubectl apply -f https://docs.projectcalico.org/v3.3/getting-started/kubernetes/installation/hosted/rbac-kdd.yaml
    ```

- workload

    - download
        ```
        wget https://docs.projectcalico.org/v3.3/getting-started/kubernetes/installation/hosted/kubernetes-datastore/calico-networking/1.7/calico.yaml
        ```
    - edit the value of CALICO_IPV4POOL_CIDR in line 278
        ```
        - name: CALICO_IPV4POOL_CIDR
            value: "10.10.0.0/16"
        ```
    - create
        ```
        kubectl apply -f calico.yaml
        ```

### Flannel

- iptables on each node
    ```
    sysctl net.bridge.bridge-nf-call-iptables=1
    ```

- workload

    ```
    kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/bc79dd1505b0c8681ece4de4c0d86c5cd2643275/Documentation/kube-flannel.yml
    ```

## Other Plugin (Master)

```
kubeadm alpha phase addon all --config ...
```

## Set Kubelet(Node)
```
kubeadm alpha phase kubelet config write-to-disk --config ...
kubeadm alpha phase kubelet write-env-file --config ...
```

```
systemctl restart kubelet
systemctl status kubelet
```

# Join(Node)
```
kubeadm join ... 
```