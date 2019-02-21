# Alpha Phase to create Kubernetes master

## Kubeadm config
```
export MASTER0_IP=192.168.1.3
export MASTER1_IP=192.168.1.4
export MASTER2_IP=192.168.1.5
export LB_IP=192.168.1.251
```


```
cat << EOF > ./kubeadm-config.yaml
apiVersion: kubeadm.k8s.io/v1alpha3
kind: InitConfiguration
bootstrapTokens:
- ttl: "0"
nodeRegistration:
  kubeletExtraArgs:
    cgroup-driver: "cgroupfs"
    max-pods: "60"
    fail-swap-on: "true"
---
apiVersion: kubeadm.k8s.io/v1alpha3
kind: ClusterConfiguration
etcd:
    external:
        endpoints:
        - http://${MASTER0_IP}:2379
        - http://${MASTER1_IP}:2379
        - http://${MASTER2_IP}:2379
networking:
  dnsDomain: cluster.local
  podSubnet: 10.10.0.0/16
  serviceSubnet: 10.96.0.0/16
kubernetesVersion: "v1.12.4"
controlPlaneEndpoint: "${LB_IP}:6443"
apiServerCertSANs:
- "apiserver-lb"
imageRepository: "k8s.gcr.io"
unifiedControlPlaneImage: "gcr.io/google_containers/hyperkube-amd64:v1.12.4"
---
apiVersion: kubeproxy.config.k8s.io/v1alpha1
kind: KubeProxyConfiguration
mode: "ipvs"
EOF
```

## Pull images
```
# kubeadm config images pull --config kubeadm-config.yaml
[config/images] Pulled gcr.io/google_containers/hyperkube-amd64:v1.12.4
[config/images] Pulled gcr.io/google_containers/hyperkube-amd64:v1.12.4
[config/images] Pulled gcr.io/google_containers/hyperkube-amd64:v1.12.4
[config/images] Pulled gcr.io/google_containers/hyperkube-amd64:v1.12.4
[config/images] Pulled k8s.gcr.io/pause:3.1
[config/images] Pulled k8s.gcr.io/coredns:1.2.2
```

## Preflight

```
kubeadm alpha phase preflight
```

### Master

```
modprobe ip_vs ip_vs_rr ip_vs_wrr ip_vs_sh nf_conntrack_ipv4
```

```
# kubeadm alpha phase preflight --config kubeadm-config.yaml  master --ignore-preflight-errors=FileAvailable--etc-kubernetes-manifests-etcd.yaml,Port-10250
[preflight] running pre-flight checks
	[WARNING FileAvailable--etc-kubernetes-manifests-etcd.yaml]: /etc/kubernetes/manifests/etcd.yaml already exists
	[WARNING Port-10250]: Port 10250 is in use
	[WARNING RequiredIPVSKernelModulesAvailable]: the IPVS proxier will not be used, because the following required kernel modules are not loaded: [ip_vs_rr ip_vs_wrr ip_vs_sh] or no builtin kernel ipvs support: map[ip_vs:{} ip_vs_rr:{} ip_vs_wrr:{} ip_vs_sh:{} nf_conntrack_ipv4:{}]
you can solve this problem with following methods:
 1. Run 'modprobe -- ' to load missing kernel modules;
2. Provide the missing builtin kernel ipvs support

[preflight] pre-flight checks passed
# echo $?
0

```

## Cert

```
kubeadm alpha phase certs all --config kubeadm-config.yaml
```

## Copy cert files

```
cat << EOF > certificate_files.txt
/etc/kubernetes/pki/ca.crt
/etc/kubernetes/pki/ca.key
/etc/kubernetes/pki/sa.key
/etc/kubernetes/pki/sa.pub
/etc/kubernetes/pki/front-proxy-ca.crt
/etc/kubernetes/pki/front-proxy-ca.key
EOF
```

```
tar -czf control-plane-certificates.tar.gz -T certificate_files.txt
```
```
USER=root # customizable
CONTROL_PLANE_IPS="192.168.1.41 192.168.1.28"
for host in ${CONTROL_PLANE_IPS}; do
    scp control-plane-certificates.tar.gz "${USER}"@$host:
done
```

## Kubeconfig

```
kubeadm alpha phase kubeconfig all --config kubeadm-config.yaml
```

## Kubelet

### Config Download
```
kubeadm alpha phase kubelet config download
```

### Config write to disk
```
# kubeadm alpha phase kubelet config write-to-disk --config kubeadm-config.yaml 
[upgrade/versions] kubeadm version: v1.12.4
[kubelet] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
```

### Config write env file
```
# kubeadm alpha phase kubelet write-env-file --config kubeadm-config.yaml 
[kubelet] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
```

## Control Plane

```
kubeadm alpha phase controlplane all --config kubeadm-config.yaml 
```

> --endpoint-reconciler-type=lease

## Start Kubelet
```
rm -rf /etc/systemd/system/kubelet.service.d/20-etcd-service-manager.conf 
systemctl daemon-reload
systemctl restart kubelet
systemctl status kubelet
```

## Upload kubelet config

```
kubeadm alpha phase kubelet config upload --config kubeadm-config.yaml
```

## Mark Master
```
kubeadm alpha phase mark-master  --node-name master0
```

## Bootstrap token
```
# kubeadm alpha phase bootstrap-token all --config kubeadm-config.yaml
[bootstraptoken] bootstrap token created
[bootstraptoken] you can now join any number of machines by running:
kubeadm join 192.168.1.250:6443 --token ao3lsf.o1vhxxbqemcvkccj --discovery-token-ca-cert-hash sha256:a199ff74d80cb67ed6247e45e881d66174907d8e0352619e2b3c1b2b764504d2
[bootstraptoken] creating the "cluster-info" ConfigMap in the "kube-public" namespace
[bootstraptoken] configured RBAC rules to allow Node Bootstrap tokens to post CSRs in order for nodes to get long term certificate credentials
[bootstraptoken] configured RBAC rules to allow the csrapprover controller automatically approve CSRs from a Node Bootstrap Token
[bootstraptoken] configured RBAC rules to allow certificate rotation for all node client certificates in the cluster

```

- check
```
# kubeadm token list
TOKEN                     TTL         EXPIRES   USAGES                   DESCRIPTION   EXTRA GROUPS
ao3lsf.o1vhxxbqemcvkccj   <forever>   <never>   authentication,signing   <none>        system:bootstrappers:kubeadm:default-node-token
```

## Upload kubeadm config
```
# kubeadm alpha phase upload-config --config=kubeadm-config.yaml
[upgrade/versions] kubeadm version: v1.12.4
[uploadconfig] storing the configuration used in ConfigMap "kubeadm-config" in the "kube-system" Namespace
# echo $?
0

```

## Install addon
```
# kubeadm alpha phase addon all --config kubeadm-config.yaml 
[addons] Applied essential addon: CoreDNS
[addons] Applied essential addon: kube-proxy
```

- Proxy
- DNS

kubeadm join 192.168.1.251:6443 --token f4dast.oyq41s0kwaob4p9c   --experimental-control-plane --ignore-preflight-errors=FileAvailable--etc-kubernetes-pki-ca.crt 


kubeadm join 192.168.1.251:6443 --token mcubzo.hhqwsed7spkdlva7 --discovery-token-ca-cert-hash sha256:e8e73718d0680504e603b3d222fa19fbe07469cfc3a0880c563bf5cd63ab9856  --experimental-control-plane --ignore-preflight-errors=DirAvailable--etc-kubernetes-manifests,Port-10250

kubeadm join 192.168.1.251:6443 --token 4u815j.nb8gryuvpgpotdop --discovery-token-ca-cert-hash sha256:770ea022dae4ea1d685f43232c170bab40e065b526616ec81211aff489b5f02c  --experimental-control-plane 

kubeadm join 192.168.1.253:6443 --token ixdnnf.s61u90d07saezdmk --discovery-token-ca-cert-hash sha256:82388b38dc5404b1ad11f0dabf229e9ae580c5dd818d4f1a4f24ee5b4d0f0d9c --experimental-control-plane --ignore-preflight-errors=FileAvailable--etc-kubernetes-manifests

### token
```
kubeadm token list 
```

### cert hash
```
openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | sed 's/^.* //'
```


## Network plugin

Install Network plugin


# Other master
```
# mkdir /data/kubernetes/pki
# rm -rf /etc/kubernetes
# ln -s /data/kubernetes /etc/kubernetes
# tar -xzf /root/control-plane-certificates.tar.gz -C /etc/kubernetes/pki --strip-components 3
```

```
# kubeadm join 192.168.1.250:6443 --token ao3lsf.o1vhxxbqemcvkccj --discovery-token-ca-cert-hash sha256:a199ff74d80cb67ed6247e45e881d66174907d8e0352619e2b3c1b2b764504d2  --experimental-control-plane --ignore-preflight-errors=FileAvailable--etc-kubernetes-manifests-etcd.yaml,Port-10250
[preflight] running pre-flight checks
	[WARNING RequiredIPVSKernelModulesAvailable]: the IPVS proxier will not be used, because the following required kernel modules are not loaded: [ip_vs_wrr ip_vs_sh ip_vs ip_vs_rr] or no builtin kernel ipvs support: map[ip_vs:{} ip_vs_rr:{} ip_vs_wrr:{} ip_vs_sh:{} nf_conntrack_ipv4:{}]
you can solve this problem with following methods:
 1. Run 'modprobe -- ' to load missing kernel modules;
2. Provide the missing builtin kernel ipvs support

[discovery] Trying to connect to API Server "192.168.1.250:6443"
[discovery] Created cluster-info discovery client, requesting info from "https://192.168.1.250:6443"
[discovery] Requesting info from "https://192.168.1.250:6443" again to validate TLS against the pinned public key
[discovery] Cluster info signature and contents are valid and TLS certificate validates against pinned roots, will use API Server "192.168.1.250:6443"
[discovery] Successfully established connection with API Server "192.168.1.250:6443"
[join] Reading configuration from the cluster...
[join] FYI: You can look at this config file with 'kubectl -n kube-system get cm kubeadm-config -oyaml'
I0116 14:36:05.826730   10194 join.go:334] [join] running pre-flight checks before initializing the new control plane instance
	[WARNING RequiredIPVSKernelModulesAvailable]: the IPVS proxier will not be used, because the following required kernel modules are not loaded: [ip_vs_wrr ip_vs_sh ip_vs ip_vs_rr] or no builtin kernel ipvs support: map[ip_vs:{} ip_vs_rr:{} ip_vs_wrr:{} ip_vs_sh:{} nf_conntrack_ipv4:{}]
you can solve this problem with following methods:
 1. Run 'modprobe -- ' to load missing kernel modules;
2. Provide the missing builtin kernel ipvs support

[kubeconfig] Wrote KubeConfig file to disk: "/etc/kubernetes/admin.conf"
[certificates] Generated front-proxy-client certificate and key.
[certificates] Generated apiserver certificate and key.
[certificates] apiserver serving cert is signed for DNS names [i-mladi07m kubernetes kubernetes.default kubernetes.default.svc kubernetes.default.svc.cluster.local apiserver-lb] and IPs [10.96.0.1 192.168.1.37 192.168.1.250]
[certificates] Generated apiserver-kubelet-client certificate and key.
[certificates] valid certificates and keys now exist in "/etc/kubernetes/pki"
[certificates] Using the existing sa key.
[kubeconfig] Using existing up-to-date KubeConfig file: "/etc/kubernetes/admin.conf"
[kubeconfig] Wrote KubeConfig file to disk: "/etc/kubernetes/controller-manager.conf"
[kubeconfig] Wrote KubeConfig file to disk: "/etc/kubernetes/scheduler.conf"
[controlplane] wrote Static Pod manifest for component kube-apiserver to "/etc/kubernetes/manifests/kube-apiserver.yaml"
[controlplane] wrote Static Pod manifest for component kube-controller-manager to "/etc/kubernetes/manifests/kube-controller-manager.yaml"
[controlplane] wrote Static Pod manifest for component kube-scheduler to "/etc/kubernetes/manifests/kube-scheduler.yaml"
[kubelet] Downloading configuration for the kubelet from the "kubelet-config-1.12" ConfigMap in the kube-system namespace
[kubelet] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
[kubelet] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
[preflight] Activating the kubelet service
[tlsbootstrap] Waiting for the kubelet to perform the TLS Bootstrap...
[patchnode] Uploading the CRI Socket information "/var/run/dockershim.sock" to the Node API object "i-mladi07m" as an annotation
[uploadconfig] storing the configuration used in ConfigMap "kubeadm-config" in the "kube-system" Namespace
[markmaster] Marking the node i-mladi07m as master by adding the label "node-role.kubernetes.io/master=''"
[markmaster] Marking the node i-mladi07m as master by adding the taints [node-role.kubernetes.io/master:NoSchedule]

This node has joined the cluster and a new control plane instance was created:

* Certificate signing request was sent to apiserver and approval was received.
* The Kubelet was informed of the new secure connection details.
* Master label and taint were applied to the new node.
* The kubernetes control plane instances scaled up.

To start administering your cluster from this node, you need to run the following as a regular user:

	mkdir -p $HOME/.kube
	sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
	sudo chown $(id -u):$(id -g) $HOME/.kube/config

Run 'kubectl get nodes' to see this node join the cluster.

root@i-mladi07m:/home/ubuntu# echo $?
0

```

```
rm -rf /etc/systemd/system/kubelet.service.d/20-etcd-service-manager.conf
systemctl daemon-reload
systemctl restart kubelet
systemctl status kubelet
```