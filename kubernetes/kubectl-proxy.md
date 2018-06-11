1. 配置访问apiserver

#### 对于非root用户
```
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

#### 对于root用户
```
export KUBECONFIG=/etc/kubernetes/admin.conf

2. kubectl proxy --port=8080 &

3. curl http://localhost:8080/apis/apps/v1/namespaces/default/deployments/server-non 
