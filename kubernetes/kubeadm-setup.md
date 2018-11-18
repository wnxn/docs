# Setup Kubernetes by kubeadm

本文旨在部署使用flannel网络插件的Kubernetes1.10集群。

## 准备工作
- 硬件要求Ubuntu 16.04+，2G RAM，2 CPU
- 禁用swap
	- 查看swap：

	```
		free
	```

	- 禁用swap：

	```
		sudo swapoff -a
	```

- 切换到root用户

```
sudo -i
```

### 安装Docker

```
apt-get update
apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository \
   "deb https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") \
   $(lsb_release -cs) \
   stable"
```

```
vim /etc/apt/sources.list
...
deb [arch=amd64] https://download.docker.com/linux/ubuntu xenial stable

```
```
apt-get update
apt-get install -y docker.io
```

### 安装kubeadm，kubelet和kubectl
kubelet版本不能超过apiserver版本

```
apt-get update && apt-get install -y apt-transport-https curl
```

```
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
```

```
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF
apt-get update
apt-get install -y kubelet kubeadm kubectl
```

### master配置cgroup选项
docker和kubelet的cgroup驱动应一致

查看docker的cgroup驱动项
```
 docker info| grep -i cgroup
```

查看kubeadm的cgroup驱动
```
cat /etc/systemd/system/kubelet.service.d/10-kubeadm.conf

```

## 创建集群

### admin执行初始化工作
```
kubeadm init --pod-network-cidr=10.244.0.0/16
```
*. 记录下kubeadm join含有密钥的命令 .*
*. 使用网络插件需传递--pod-network-cidr=10.244.0.0/16参数 .*

### 配置访问apiserver

#### 对于非root用户
```
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

#### 对于root用户
```
export KUBECONFIG=/etc/kubernetes/admin.conf
```

### 安装网络插件
kubeadm仅支持基于CNI的网络

#### kubeadm init时需传递网络参数
`--pod-network-cidr=10.244.0.0/16 `

#### 将IPv4流量传递到iptables链中

```
sysctl net.bridge.bridge-nf-call-iptables=1
```

#### 创建 Flannel daemonset (可选择)

```
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/v0.9.1/Documentation/kube-flannel.yml
```

#### 创建 Calico （可选择）

```
kubectl apply -f https://docs.projectcalico.org/v3.1/getting-started/kubernetes/installation/hosted/rbac-kdd.yaml
```

> 修改 Pod CIDR
```
wget https://docs.projectcalico.org/v3.1/getting-started/kubernetes/installation/hosted/kubernetes-datastore/calico-networking/1.7/calico.yaml
```

### 调度pod给master（可选）
给master添加taint

```
kubectl taint nodes --all node-role.kubernetes.io/master-
```

### node加入集群

```
kubeadm token create
kubeadm join ...
kubeadm join 192.168.1.13:6443 --token ip7z2d.55k6h6i2gbm72sjb --discovery-token-ca-cert-hash sha256:0854371de4b316007cd3cdc2acc32d4091e91551b074a082054d63ee7ed750b2
```

```
kubeadm token list
kubeadm join --discovery-token-unsafe-skip-ca-verification --token=102952.1a7dd4cc8d1f4cc5 172.17.0.54:6443
```

## Tips
1. 官方安装手册： https://kubernetes.io/docs/setup/independent/install-kubeadm/#verify-the-mac-address-and-product_uuid-are-unique-for-every-node
2. kubeadm init参数手册： https://kubernetes.io/docs/reference/setup-tools/kubeadm/kubeadm-init/#config-file
3. kubeadm reset：可重置节点配置