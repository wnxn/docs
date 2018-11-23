# Kubernetes CSI Version List
|Component|Version|Date|
|:---:|:---:|:---:|
|Provisioner|v1.0.0|Fri, Nov 16, 2018 7:23 AM|
|Attacher|v1.0.0|Fri, Nov 16, 2018 11:14 AM|
|Snapshotter|v1.0.0|Tue, Nov 20, 2018 2:14 PM|
|driver registrar|v1.0.0|Fri, Nov 16, 2018 6:56 AM|
|liveness probe|v0.4.1|Tue, Oct 23, 2018 11:22 AM|

# Work List
## Community
1. 删除 volume 时信息过少
2. 增加 NFS 示例，说明 Topology
3. 明确推荐的部署架构
4. 增加 CSI v0.2.0 在 Kubernetes v1.12部署经验 [已提PR]

## QingCloud
1. QingCloud CSI: upgrade to CSI 1.0, snapshot, usage, topology, HA
2. NAS 需求: RWX, 清理过期文件，扩容，监控。
# How to develop CSI plugin
## Principle
1. 不要将 PVC 和 Snapshot YAML 文件放在一起，创建延时问题。

## Advice