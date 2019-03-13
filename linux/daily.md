## Kubeadm --kubeconfig 参数 BUG
### 情况
Kubernetes v1.12 中 kubeadm alpha phase addon kube-proxy --config ${KUBEADM_CONFIG_PATH} --kubeconfig /root/.kube/config 这条命令 kubeconfig 设置后无效

### 排查
kubernetes/cmd/kubeadm/app/cmd/phase/addons.go L67 应增加 kubeConfigFile := kubeadmconstants.GetAdminKubeConfigPath()

对比的是 kubernetes/cmd/kubeadm/app/cmd/phase/uploadconfig.go L 53 行有这句

### 状态
待修复，还需确认最新版 Kubernetes Kubeadm 情况