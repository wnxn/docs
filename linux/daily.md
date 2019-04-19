## Kubeadm --kubeconfig 参数 BUG
### 情况
Kubernetes v1.12 中 kubeadm alpha phase addon kube-proxy --config ${KUBEADM_CONFIG_PATH} --kubeconfig /root/.kube/config 这条命令 kubeconfig 设置后无效

### 排查
kubernetes/cmd/kubeadm/app/cmd/phase/addons.go L67 应增加 kubeConfigFile := kubeadmconstants.GetAdminKubeConfigPath()

对比的是 kubernetes/cmd/kubeadm/app/cmd/phase/uploadconfig.go L 53 行有这句

### 状态
待修复，还需确认最新版 Kubernetes Kubeadm 情况

## Kubeadm --kubeconfig 参数 BUG
### 情况
Kubeadm 1.12.7 kubeadm alpha phase kubelet config write-to-disk --config kubeadm-config.yaml 设置 kubelet /var/lib/kubelet/config.yaml 的--anonymous-auth=true --authorization-mode=AlwaysAllow 无效。
Kubeadm 1.13.5 kubeadm init 时 kind: KubeletConfiguration apiVersion: kubelet.config.k8s.io/v1beta1 的authentication里的 anonymous 设置无效

### 原因
可能是 DynamicKubeletConfiguration=true 的原因，设置为 false 尝试

## Kubeadm proxy 设置 ExtraArgs feature

### 添加 ExtraArgs 参数
在 pkg/proxy/apis/config/types.go#L147 增加 
```
	// ExtraArgs is an extra set of flags to pass to the kube-proxy.
	ExtraArgs map[string]string
```
在 https://github.com/kubernetes/kubernetes/blob/release-1.13/staging/src/k8s.io/kube-proxy/config/v1alpha1/types.go#L141 增加
```
 ExtraArgs map[string]string `json:"extraArgs,omitempty"`
```

### 使 ExtraArgs 参数生效
- 仿照 kubelet 处理方式
- 研究 proxy 其他参数处理方法
https://github.com/kubernetes/kubernetes/commit/281f2ad51ecee0144d63e0a670e374e6c7136b46
