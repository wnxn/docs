# Load Balancer

## 1. 基于 NAT

NAT 方法是在 Kubernetes 集群外部署一台 Linux 主机（称为 NAT 主机），类似 LB 功能。原理是通过 iptables 的 NAT 功能将用户请求的 IP 数据包传输至 NAT 主机后，将 EIP 和 请求的端口 进行 DNAT 转换为 Kubernetes 节点 IP 与 Node Port，响应用户请求。

### 1.1 前提条件

- ubuntu 16.04
- EIP
- Kubernetes cluster

### 1.2 Kubernetes 集群内部

- Create Service in Kubernetes

```
kubectl run tomcat --image=tomcat:8.0-alpine --replicas=2
```

```
kind: Service
apiVersion: v1
metadata:
  name: lb-service
spec:
  selector:
    run: nginx
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
  type: LoadBalancer
  externalIPs:
  - 139.198.121.XX
```

### 1.3 在 NAT 主机
- Add Network Device

[Add Network Device](https://docs.qingcloud.com/product/network/eip#%E4%BD%BF%E7%94%A8%E5%86%85%E9%83%A8%E7%BB%91%E5%AE%9A%E5%85%AC%E7%BD%91-ip)

- Enable Network Device
```
ifdown eth1
ifup eth1
```

- Enable IP forward

```
sysctl net.ipv4.ip_forward=1
```

- Add NAT iptables
```
iptables -t nat -A PREROUTING -p tcp -d EIP --dport NODE_PORT -j DNAT --to-destination K8S_NODE_IP:NODE_PORT

iptables -t nat -A POSTROUTING -j MASQUERADE
```

### 1.4 结果
```
curl EIP:NODE_PORT
```
- On NAT host: failed
- On K8S node: succeed
- On other host: succeed

## 2 基于交换机

基于交换机的方案原理是借助交换机的路由功能将用户请求的 IP 数据包转发到 Kubernetes 集群的节点上，Kubernetes 集群需要配置路由规则接受目的地址为 EIP 的 IP 数据包，响应用户请求。

### 2.1 在 Kubernetes 集群内部
- Create Service in Kubernetes

```
kubectl run tomcat --image=tomcat:8.0-alpine --replicas=2
```

```
kind: Service
apiVersion: v1
metadata:
  name: lb-service
spec:
  selector:
    run: nginx
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
  type: LoadBalancer
  externalIPs:
  - 139.198.121.XX
```

- Add Route on Kubernetes Host
```
ip route replace local 0/0 dev lo table 100 
ip rule add to 139.198.121.0/24 lookup 100

ip route replace default via K8S_NODE_IP dev eth0 table 101 
ip rule add from 139.198.121.0/24 lookup 101
```

### 2.2 在交换机上
- Add Network Device

[Add Network Device](https://docs.qingcloud.com/product/network/eip#%E4%BD%BF%E7%94%A8%E5%86%85%E9%83%A8%E7%BB%91%E5%AE%9A%E5%85%AC%E7%BD%91-ip)

- Add Route
```
ip route replace default dev eth1
ip route replace 139.198.121.XX via K8S_NODE_IP dev eth0
```

- Enable Package Forward
```
sysctl -w net.ipv4.ip_forward=1 
sysctl -w net.ipv4.conf.all.rp_filter=0 
sysctl -w net.ipv4.conf.eth1.rp_filter=0 
sysctl -w net.ipv4.conf.eth0.rp_filter=0
```

### 2.3 结果
```
curl EIP:NODE_PORT
```
- On Switch host: succeed
- On K8S node: failed
- On other host: succeed

## 3 比较

### 耦合性上
- NAT 方案在 NAT 主机配置 iptable 规则
- 基于交换机方案需要在交换机和 Kubernetes 节点配置路由规则

基于交换机方案实现较复杂，需要对 Kubernetes 节点配置路由规则。

### 功能性上
- NAT 方案可以在用户本地，K8S 集群内部通过 EIP 访问服务
- 基于交换机方案只能在用户本地通过EIP访问服务

基于交换机方案无法在 Kubernetes 集群内部使用 EIP 访问集群内服务

## 4 不足

- 青云云平台一台主机只能绑定1个 EIP，目前实验是创建一个 LB Service 进行原理验证。

## Reference
[How-To: Redirecting network traffic to a new IP using IPtables](https://www.debuntu.org/how-to-redirecting-network-traffic-to-a-new-ip-using-iptables/)