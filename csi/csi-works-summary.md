# Kubernetes CSI Version List
Provisioner 
    v1.0.1 2018-12-6
    v1.1.0 2018-04-13 CSI v1.0.0 K8s v1.14
Attacher    
    v1.0.1 2018-12-6
    v1.1.0 2018-04-5 CSI v1.0.0 k8s v1.14
Snapshotter    
    v1.0.1 2018-12-6
    v1.1.0 2018-4-18
Resizer
    v0.1.0 2019-04-04 csi v1.1.0,k8s v1.14.0 docker pull quay.io/k8scsi/csi-resizer:v0.1.0
driver registrar
    v1.0.1 2018-11-21
    v1.1.0 废弃，改为 cluster-driver-registrar 和 node-driver-registrar
cluster-driver-registrar
    v1.0.1 2018-12-19 k8s v1.14
node-driver-registrar
    v1.1.0 2019-04-13
liveness probe  
    v1.0.0  2018-11-19
    v1.1.0  2019-04-16
csi-test
    v2.0.0 2019-04-02 适配 CSI v1.1.0

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


# QingCloud Block Storage Verify
## 用例

> Volume capacity 50 GB, used 20 GB, format EXT4

- 如何创建快照，耗时，快照大小（50 G 存储卷，20 G 内容, ext4）？ 4m 30s
- 如何删除快照，耗时？3min
- 删除存储卷后快照是否可用？ 可用
- 从快照恢复存储卷耗时（50 G 存储卷，20 G 内容, ext4）？3m 50s

- 能否从 HP 快照恢复为 SHP 的存储卷？否

- 一个存储卷能否创建多个全量快照？ 是

- 克隆硬盘

- 扩容硬盘

    - 必须大于原volume容量，HP增量为10GB。必须与主机解绑， 不能在线扩容。

- 硬盘用量数据

疑问
- 快照命令一发送就 cut 吗？创建快照时写入数据会怎么样？
- 进度条怎么得来的？
- CLI 没有 克隆volume 命令?
- 硬盘监控如何得到的