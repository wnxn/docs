# Files

- [asd](#Access-Apiserver-by-SA)

## Find Files Containing Specific Word

```
grep -R --include="*.go" storage-class ./
```

## Kubesphere

```
$ git diff pkg/app/app.go 
-       go controllers.Run()

```

## delete secret in different namespace
```
kubectl get ns --no-headers=true | awk '{print $1}' | xargs -i kubectl delete secret ceph-secret-user -n {}
```

## Save Files

```
cat <<EOF | sudo tee /the/file/path/filename
file context...
EOF
```

## Free Password Login

```
ssh-keygen
ssh-copy-id -i ~/.ssh/id_rsa.pub root@192.168.1.16
```

## LC_TYPE

```
export LC_ALL="en_US.UTF-8"
export LC_CTYPE="en_US.UTF-8"
```

## Scp

```
scp -rP 10104 ./office root@192.168.176.56:~/
```

## Crt
```
openssl x509 -noout -text -in ./apiserver.key
```

# Volume

## Mount table

```
cat /proc/mounts
```

## Glusterfs topology

```
heketi-cli topology info
```

## Mount Propagation Feature Gate
```
/etc/kubernetes/kubelet.env
```

## CSI Sanity Test

```
./csi-sanity --csi.endpoint=/var/lib/kubelet/plugins/csi-qingcloud/csi.sock
```

# Go

## Installation

> https://golang.org/doc/install
```
wget https://dl.google.com/go/go1.11.2.linux-amd64.tar.gz
tar -xf go1.11.2.linux-amd64.tar.gz
mv go /usr/local
```

```
echo 'export GOPATH=/root/mygo' >> /etc/profile
echo 'export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin:/usr/local/bin' >> /etc/profile
source /etc/profile
go version
mkdir -p /root/mygo/src /root/mygo/pkg /root/mygo/bin
```

## Dep install
```
curl https://raw.githubusercontent.com/golang/dep/master/install.sh | sh
```

## Test one testfile

```
go test -v instance_manager_test.go  instance_manager.go volume_manager.go util.go storage_class.go -count=1
```

## Test one function
```
go test -v util_test.go util.go  -test.run TestByteCeilToGb -count=1
```
## Test output log

```
func TestMain(m *testing.M) {
        flag.Set("alsologtostderr", "true")
        flag.Set("log_dir", "/tmp")
        flag.Set("v", "3")
        flag.Parse()
        ret := m.Run()
        os.Exit(ret)
}
```


## GO report
[![Go Report Card](https://goreportcard.com/badge/github.com/yunify/qingcloud-csi)](https://goreportcard.com/report/github.com/yunify/qingcloud-csi)

[![Go Report Card](https://goreportcard.com/badge/github.com/yunify/qingcloud-csi)](https://goreportcard.com/report/github.com/yunify/qingcloud-csi)

# Kubernetes

## build binary

```
CGO_ENABLED=0 GOOS=linux go build -a -ldflags '-extldflags "-static"' -o  _output/${BLOCK_PLUGIN_NAME} cmd/kubeadm/kubeadm.go
```

## Access Apiserver by SA

```
$ APISERVER=$(kubectl config view | grep server | cut -f 2- -d ":" | tr -d " ")
$ TOKEN=$(kubectl describe secret $(kubectl get secrets | grep default | cut -f1 -d ' ') | grep -E '^token' | cut -f2 -d':' | tr -d '\t')
$ curl -i -H "Authorization: Bearer TOKEN" https://192.168.0.80:6443/api/v1/namespaces/default/services/kubernetes
```

## Cloud Native

- Horizontally scalable
- No single point of failure
- Resilient and self healing
- Minimal operator overhead
- Decouple from the underlying platform

## Scheduler Tolerance Everything
```
tolerations:
- operator: "Exists"
```
# Mac

## Daemon app
```
brew services list
```

## volume  service
```
sudo kill -9 `ps ax|grep 'coreaudio[a-z]' |awk '{print $1}'` 
```

# Git

## Big file
```
git config --global http.postBuffer 524288000 
```

### Issues label
```
NEW FEATURES:
BUG FIXES:
IMPROVEMENTS:
```
