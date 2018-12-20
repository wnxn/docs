## Useful Advice

### CIDR

service ip: api-server service-cluster-ip-range=10.233.0.0/18
kubeadm init --service-cidr 10.96.0.0/12

pod id: controller-manager --cluster-cidr=10.233.64.0/18

### Rule

1. It’s recommended that you join new control plane nodes only after the first node has finished initializing.
1. Use LOAD_BALANCER_DNS other than LOAC_BALANCER_IP
1. Copy certificates between the first control plane node and the other control plane nodes.
1. Join each control plane node with the join command you saved to a text file, plus add the --experimental-control-plane flag.

### Stacked HA cluster

```
kubeadm init
kubeadm join --experimental-control-plane
```

### Docker Install

> NOTE: Latest validated version 18.06

```
https://docs.docker.com/install/linux/docker-ce/ubuntu/#upgrade-docker-ce-1
```

```
apt-get install docker-ce=18.06.1~ce~3-0~ubuntu
```

### View Certificate


- CRT转CER

    openssl x509 -in 你的证书.crt -out 你的证书.cer -outform der

- 查看CRT内容

    openssl x509 -in 你的证书.crt -text -noout

- 查看.KEY文件

    openssl rsa -in 你的证书.key -text -noout

- 查看.CSR文件

    openssl req -noout -text -in 你的证书.csr

