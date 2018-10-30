# Load Balancer

## 1. NAT Based
### 1.1 Prerequsite

- ubuntu 16.04
- EIP
- Kubernetes cluster

### 1.2 In Kubernetes cluster

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
  loadBalancerIP: 139.198.121.XX
  type: LoadBalancer
  externalIPs:
  - 139.198.121.XX
```

### 1.3 On NAT host
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

### 1.4 Result
```
curl EIP:NODE_PORT
```
- On NAT host: failed
- On K8S node: succeed
- On other host: succeed

## 2 Route Based

### 2.1 In Kubernetes
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
  loadBalancerIP: 139.198.121.XX
  type: LoadBalancer
  externalIPs:
  - 139.198.121.XX
```

- Add Rout on Kubernetes Host
```
ip route replace local 0/0 dev lo table 100 ip rule add to 139.198.121.0/24 lookup 100

ip route replace default via K8S_NODE_IP dev eth0 table 101 ip rule add from 139.198.121.0/24 lookup 101
```

### 2.2 On Switch
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

### 2.3 Result
```
curl EIP:NODE_PORT
```
- On Switch host: succeed
- On K8S node: failed
- On other host: succeed

## Reference
[How-To: Redirecting network traffic to a new IP using IPtables](https://www.debuntu.org/how-to-redirecting-network-traffic-to-a-new-ip-using-iptables/)