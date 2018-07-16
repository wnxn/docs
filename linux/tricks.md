# Files

## find files containing words

```
grep -R --include="*.go" storage-class ./
```

## save files

```
cat <<EOF | sudo tee /the/file/path/filename
file context...
EOF
```

## free password login

```
ssh-keygen
ssh-copy-id -i ~/.ssh/id_rsa.pub root@192.168.1.16
```

## LC_TYPE

```
export LC_ALL="en_US.UTF-8"
export LC_CTYPE="en_US.UTF-8"
```

## scp

```
scp -rP 10104 ./office root@192.168.176.56:~/
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

# Go

## Test one testfile

```
go test -v mount_test.go TestRefreshAccessToken -count=1
```

## GO report
[![Go Report Card](https://goreportcard.com/badge/github.com/yunify/qingcloud-csi)](https://goreportcard.com/report/github.com/yunify/qingcloud-csi)

# CSI

## csi-test

```
./csi-sanity --csi.endpoint=/var/lib/kubelet/plugins/csi-qingcloud/csi.sock
```

## access apiserver by secret account toekn

```
$ APISERVER=$(kubectl config view | grep server | cut -f 2- -d ":" | tr -d " ")
$ TOKEN=$(kubectl describe secret $(kubectl get secrets | grep default | cut -f1 -d ' ') | grep -E '^token' | cut -f2 -d':' | tr -d '\t')
$ curl -i -H "Authorization: Bearer TOKEN" https://192.168.0.80:6443/api/v1/namespaces/default/services/kubernetes
```
