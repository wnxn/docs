## Introduction

|||
|-----|----|
|Pod CIDR|172.100.0.0/16|
|PREFIX|24|
|Cluster IP|10.254.0.0/16|
|OS|Ubuntu16.04|
|Core|8Core|
|RAM|16GB|
|Disk|40GB|

Git URL: https://github.com/wnxn/docs.git

## Cfssl

https://kubernetes.io/docs/concepts/cluster-administration/certificates/
```
curl -L https://pkg.cfssl.org/R1.2/cfssl_linux-amd64 -o cfssl
chmod +x cfssl
curl -L https://pkg.cfssl.org/R1.2/cfssljson_linux-amd64 -o cfssljson
chmod +x cfssljson
curl -L https://pkg.cfssl.org/R1.2/cfssl-certinfo_linux-amd64 -o cfssl-certinfo
chmod +x cfssl-certinfo
```

## Kubelet
```
/var/lib/kubelet/kubeadm-flags.env
/var/lib/kubelet/config.yaml
```
