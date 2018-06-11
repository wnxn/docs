# Services, Load Balancing, and Networking

## Services
K8S中Service资源对象简写为SVC
https://kubernetes.io/docs/concepts/services-networking/service/#headless-services

- 使得前端无需感知后端存在，解耦合。
- Kubernetes原生应用：提供简单的Endpoints更新Service选择的Pod的状态。
- 非原生应用：Kubernetes提供基于virtual-IP的Service指向后端Pod
- SVC的targetPort可以是别名，别名定义在Pod中，指向真正的端口
- SVC支持TCP（默认）和UDP

### 转发方式

#### userspaces
#### iptables
- iptables实现SVC不能自动重试Pod的连接，依赖于readiness probes
- 与userspaces不同的是数据包不会拷贝至用户态

#### ipvs `v1.9 beta`
* kube-proxy监视SVC和EP，调用netlink接口创建对应的ipvs规则并周期性地同步SVC和EP的ipvs规则
* ipvs基于netfilter hook功能。使用hash表作为底层数据结构，并工作在内核空间。
* ipvs转发流量快，同步代理规则时有更好的性能。ipvs有更多负载均衡算法。
  - rr：round-robin
  - lc: least connection
  - dh: destination hashing
  - sh: source hashing
  - sed: shortest expected delay
  - nq: never queue
* 需要安装IPVS内核模块，当没有安装时，使用iptables代理模式
* 大规模集群适用(10000个SVC)

### 种类
1. 普通Service
2. 无selector SVC
  1. SVC指定端口，须指定EP
  2. SVC不指定端口，ExternalName SVC，返回一个别名。
3. headless svc 无clusterIP的svc
  1. 有selector，DNS能返回后端Pod的A记录
  2. 无selector，要么配置ExternalName为CNAME，要么与svc共享名字的ep记录

```
A记录：域名解析到一个IP地址
CNAME：主机名指向别名
```

|   类型     |  解释            | 备注|
|-------|-------------|-------------|
|ClusterIP   |  最普通，供集群内部使用 |无 |
|NodePort   |  接入外部流量的普通svc | v1.10的kube-proxy设置--nodeport-address，选择所转发的网段|
|LoadBalancer   | 使用云提供商的lb  |无 |
|ExternalName   | 将svc名映射为一个CNAME  |kube-dns v1.7+ |
|headless svc   | 用于有状态应用或历史遗留应用  | 与statefulset配合    |
|无selector svc   | 用于连接外部应用  | 需额外配置ep    |
|ingress   | 7层路由  | 配置不同url寻找后端pod  |
|ExternalIP   | 外部直接访问  |    |

## virtual IP背后的细节

### 避免冲突
- 保证隔离性，为每个service分配IP地址。
- 分配之前查询etcd

### IPs和VIPs
见本文前面部分
