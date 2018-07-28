## Download etcdctl
```
wget https://github.com/coreos/etcd/releases/download/v3.3.9/etcd-v3.3.9-linux-amd64.tar.gz
tar -xf etcd-v3.3.9-linux-amd64.tar.gz
```

## Security Etcd
```
cert-file
key-file
peer-cert-file
peer-key-file
peer-trusted-ca-file
trusted-ca-file
```

## Access Etcd

```
ETCDCTL_API=3 etcdctl get / --prefix --keys-only=true
  --endpoints=https://[127.0.0.1]:2379 --cacert=./ca.crt --cert=./server.crt --k
ey=./server.key
./etcdctl get / --prefix --keys-only=true --endpoints=https://127.0.0.1:2379 --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/server.crt --key=/etc/kubernetes/pki/etcd/server.key
```i

## View Cert
```
openssl x509  -noout -text -in ./server.crts
```