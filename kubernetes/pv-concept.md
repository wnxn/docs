# Persistent Volumes

## 介绍

- 管理存储独立于管理计算。
- PV为用户和管理员提供API，抽象了存储的细节。

### 介绍PV和PVC

#### PV
- PV由管理员提供给集群的。
- PV的生命周期独立于使用PV的Pod

#### PVC
- PVC是由用户请求的存储。
- PVC消耗PV资源，类似Pod消耗Node资源
- PVC请求特定的容量和访问模式，类似Pods请求特别的CPU和内存资源

#### PVC和PV联系
- 虽然PVC允许用户消耗抽象存储资源，用户面对不同问题普遍需要不同属性的PV，例如性能。
- 管理员不仅仅按容量和访问模式提供不同种类的PV，也不要将底层卷实现暴露给用户。实现这些需求将与`StorageClass`相关
- PV和PVC是一一映射的，PVC一旦绑定PV就是独占的，不可再分配。

## PV和PVC生命周期
- PV是集群内的资源，PVC是对于资源的请求

### PVC使用的流程
#### 供应（Provisioning）
分为`静态`和`动态`两种供应方法
##### 静态分配
- 集群管理员创建大量PV，
- PV包含集群用户所用存储的详细信息。
- PV在Kubernetes API存在并可以被使用

##### 动态分配
- 当没有静态PV满足用户PVC时，集群会尝试动态分配卷供PVC使用。
- 这个卷供应是基于StorageClasses：PVC请求StorageClass，管理员创建和配置StorageClass
- 启用StorageClasses配置，kube-apiserver要增加DefaultStorageClass配置
  - DefaultStorageClass配置给没有选择特定StorageClass的PVC分配默认StorageClass类别的PV。
  - 若没有设置StorageClasses，PVC必须指定StorageClass类别
  - 若设置多个StorageClasses，PVC创建出错

#### 绑定（Binding）
- 当用户PVC已经申请到存储资源后，寻找匹配的PV，并绑定。
- 若PV是为PVC动态分配的，总是将此PV绑定到PVC。
- `PVC和PV的绑定是一一映射的`

#### 使用（Using）
- Pod使用claim作为volume卷挂载
  - 集群检查claim寻找绑定的卷，并将卷挂载到pod
  - 对于volumes，支持多种访问模式，用户指定希望使用的模式
- 一旦用户有了一个claim，claim产生了绑定，绑定的PV属于用户。
- 用户调度Pod并访问申请的PV

#### 保护使用中的存储对象 `v1.10 beta`
https://kubernetes.io/docs/tasks/administer-cluster/storage-object-in-use-protection/
- 确保PVC被pod使用时（包括Pod处于Pending并调度到Node中，或Running状态），PVC所绑定的PV不会从系统中移除。
- 用户要删除使用中的PVC，PVC删除将会推迟，直到PVC不再活跃。
- 如果管理员删除绑定到PVC的PV，此PV会推迟删除，直到PV不再绑定到PVC

#### 回收（Reclaiming）
- 当PVC对象删除后，允许回收PV资源。
- 目前卷可以Retained（保留）,Recycled（回收），Deleted（删除）
  - Retain
    - 允许手工回收资源
    - 当PVC删除后，PV仍然存在，volume被认为是释放的，因为PV里还有数据，但不可被别的claim使用。
    - 管理员需手动回收这些volume
      1. 删除PV，关联的外部存储仍然存在
      2. 手动清除关联存储内的数据
      3. 手动删除关联存储的资源，如果想重新使用同样的存储资源，创建新的PV
  - Delete
    - 对于支持Delete回收策略的卷插件，删除操作会删除PV对象也会删除关联的外部存储资源。
    - 动态分配的卷会继承StorageClass的回收策略
  - Recycle
    - 目前被废弃，建议用动态分配替代

#### 扩展PVC
- 通过设置`ExpandPersistentVolumes`由管理员扩展PVC，实现Resize功能。扩展后端PV功能，而非创建新的PV。
- 对于含有文件系统的卷的扩展，文件系统的大小调整仅仅当新的Pod启动并且PVC在RW模式下执行。换言之，如果一个卷在被Pod或deployment使用时扩展时，由于文件系统调整了，你将需要删除并重新创建Pod。文件系统调整仅支持XFS，EXT3，EXT4.
- ESB卷扩展是一项耗时的操作，每个卷修改一次要花6小时。

## PV字段详解
### 容量 （Capacity属性）
- PV有特定的存储容量，
- 目前仅有存储空间可以被设置，未来可以设置IOPS，吞吐量等属性

### 卷模式 （volumeMode属性）
- v1.9之前的版本，卷插件的默认行为是在PV上创建文件系统
- v1.9时，用户可以指定volumeMode(alpha)为`文件系统`和`原始块`，对于volumeMode来说，`Filesystem`和`Block`是有效的值。如果未指定，volumeMode为`Filesystem`

### 访问模式
- RWO - ReadWriteOnce
- ROX - ReadOnlyMany
- RWX - ReadWriteMany

### Class （storageClassName属性）
- PV可以拥有一个class，可以通过设置storageClassName熟悉指定StorageClass名字。
- 属于特定class的PV可以被PVC所请求的class所绑定。
- 无class的PV仅可以被未指定class的PVC所绑定。

### 回收策略
PVC删除后的PV回收策略
- Retain 保留 手动回收
- Recycle 回收 （废弃，动态分配替代）
- Delete 会关联删除相关的外部存储
- 目前 NFS和HostPath支持回收，AWS EBS，GCE PD,Azure, Cinder支持删除

### Expanding Persistent Volumes Claims
`resize功能`
- k8s v1.8 alpha 支持扩展PV
- k8s v1.9 gce,aws,cinder,glusterfs,rbd支持pvc扩展。仅支持storageclass的resize
- 扩展有filesystem的数据卷，需要重新创建卷可读写的Pod，仅支持XFS，ext3，ext4


### 挂载选项 （mountOptions属性）

### Phase 阶段
- Available 还没绑定到claim的自由资源
- Bound 卷已绑定到claim
- Released claim已删除，资源还未由集群收回
- Failed 卷自动回收失败

## PVC字段详解
### 访问模式（Access Mode）
- 与PV一样
- RWO - ReadWriteOnce
- ROX - ReadOnlyMany
- RWX - ReadWriteMany
### 卷模式（Volume Mode）
- Filesystem or Block
### 资源
- 申请的容量
### Selector
- 过滤选择volumes用，请求筛选是AND并集
- 含有selector的PVC不能通过动态分配PV
### Class
- 指定某种storageClassName的class
- PVC的storageClassName设为“”，表明绑定的PV的storageClassName为“”
- PVC的没有设置storageClassName，要与DefaultStorageClass一致，DefaultStorageClass关闭时，等同于设置storageClassName为“”的PVC

## 请求作为卷
- Pod定义中的volume可以是pvc也可以是具体类型

## 原始块卷支持
- 对于原始块卷的静态分配支持，在`v1.9 alpha`
- `v1.10`支持Fibre Channel（光纤通信）和Local Volume Plugin
- PV和PVC定义中volumeMode属性为Block
- Pod定义中要指定spec.containers.volumeDevices.devicePath属性
- PV和PVC的volumeMode字段变化与绑定结果之间绑定矩阵结果见网页中此部分

## 编写可移植配置建议
- 要包含PVC定义
- 不要包含PV定义，用户可能没有创建PV权利
- 当实例化模板时，给用户提供storage class的选项
  - 用户提供storage class名字时，将名字放入pod spec中，需要管理员做相应配置
  - 用户没有提供storage class名字时，将名字放入pod spec对应字段为nil。使得PV自动按DefaultStorageClass创建PV。
- 要时刻关注未绑定PV的PVC，并告诉用户。可能是集群没有动态存储（当用户创建PV时），可能集群没有存储系统（当用户不能创建PVC时）


## 问题
1. 当有一个PVC时，静态和动态PV供应的先后顺序是什么样的？
    - 先静态分配，查看有无PV，无PV再考虑 storageclass动态分配
2. PVC申请时会是最节约方式分配吗？
    - 动态分配是的。
3. storageClass是管理员还是用户创建，是属于namespace资源吗？
    - 管理员创建，不属于特定的namespace

## 参考文献
1. PV使用范例 [https://kubernetes.io/docs/tasks/configure-pod-container/configure-persistent-volume-storage/]
2. StorageClass
[https://kubernetes.io/docs/concepts/storage/storage-classes/]
3. 配置StorageClass
[https://kubernetes.io/docs/admin/admission-controllers/#defaultstorageclass]
[https://kubernetes.io/docs/reference/generated/kube-apiserver/]
4. PVC容量扩展[https://kubernetes.io/docs/admin/admission-controllers/#persistentvolumeclaimresize]

sc关联的pvc