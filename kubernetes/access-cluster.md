## 配置访问apiserver

### 对于非root用户
```
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

### 对于root用户
```
export KUBECONFIG=/etc/kubernetes/admin.conf

2. kubectl proxy --port=8080 &

3. curl http://localhost:8080/apis/apps/v1/namespaces/default/deployments/server-non 
```

## 选择 API

### 按 label 选择
```
root@dev:~# kubectl get po --all-namespaces --selector=app=csi-qingcloud
NAMESPACE     NAME                         READY   STATUS    RESTARTS   AGE
kube-system   csi-qingcloud-controller-0   3/3     Running   0          23h
kube-system   csi-qingcloud-node-vg2bt     2/2     Running   0          23h
```

```
root@dev:~# kubectl get po --all-namespaces --selector=app=csi-qingcloud --v=6
I1128 14:39:44.604229   31819 loader.go:359] Config loaded from file /root/.kube/config
I1128 14:39:44.605107   31819 loader.go:359] Config loaded from file /root/.kube/config
I1128 14:39:44.612592   31819 loader.go:359] Config loaded from file /root/.kube/config
I1128 14:39:44.627318   31819 loader.go:359] Config loaded from file /root/.kube/config
I1128 14:39:44.644757   31819 round_trippers.go:405] GET https://192.168.1.2:6443/api/v1/pods?labelSelector=app%3Dcsi-qingcloud&limit=500 200 OK in 16 milliseconds
I1128 14:39:44.646272   31819 get.go:558] no kind is registered for the type v1beta1.Table in scheme "k8s.io/kubernetes/pkg/api/legacyscheme/scheme.go:29"
NAMESPACE     NAME                         READY   STATUS    RESTARTS   AGE
kube-system   csi-qingcloud-controller-0   3/3     Running   0          23h
kube-system   csi-qingcloud-node-vg2bt     2/2     Running   0          23h
root@dev:~# 

```