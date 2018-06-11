# CSI总结

## 组件介绍
- CSI Volume Plugin： 内置在k8s代码里，随k8s编译，发布
- External Provisioner： K8S官方维护，作为Plugin与Driver通信桥梁，watch PVC对象，负责PV创建和删除工作
- External Attacher： K8S官方维护，作为Plugin与Driver通信桥梁，watch VA对象，负责卷attach与detach工作
- CSI Volume Driver： 存储商提供，对具体网络存储操作

## 要求
### 启用mount propagation
docker daemon的启动service文件需要加上`MountFlags=shared`。
并重启docker

## Kubernetes推荐方案
### 组件架构图
Master运行External Provisioner， External Attacher， CSI Volume Driver
Node运行CSI Volume Driver
```
                             CO "Master" Host
+-------------------------------------------+
|                                           |
|  +------------+           +------------+  |
|  |     CO     |   gRPC    | Controller |  |
|  |            +----------->   Plugin   |  |
|  +------------+           +------------+  |
|                                           |
+-------------------------------------------+

                            CO "Node" Host(s)
+-------------------------------------------+
|                                           |
|  +------------+           +------------+  |
|  |     CO     |   gRPC    |    Node    |  |
|  |            +----------->   Plugin   |  |
|  +------------+           +------------+  |
|                                           |
+-------------------------------------------+
```

### 动态分配PVC生命周期
```
   CreateVolume +------------+ DeleteVolume
 +------------->|  CREATED   +--------------+
 |              +---+----+---+              |
 |       Controller |    | Controller       v
+++         Publish |    | Unpublish       +++
|X|          Volume |    | Volume          | |
+-+             +---v----+---+             +-+
                | NODE_READY |
                +---+----^---+
               Node |    | Node
            Publish |    | Unpublish
             Volume |    | Volume
                +---v----+---+
                | PUBLISHED  |
                +------------+
```

## 参考资料
1. K8S官网对于CSI说明：https://kubernetes.io/blog/2018/04/10/container-storage-interface-beta/
2. K8S CSI Git主页详细说明：https://github.com/kubernetes/community/blob/master/contributors/design-proposals/storage/container-storage-interface.md
3. K8S CSI手册：https://kubernetes-csi.github.io/docs/Home.html
4. CSI Git主页详细说明：https://github.com/container-storage-interface/spec/blob/master/spec.md

### CSI创建时序图
```
title CSI方法动态分配时序图
participant APIserver as A
participant "Controller Manager" as C
participant Kubelet as K
participant "CSI Volume Plugin" as P
participant "External Provisioner" as EP
participant "External Attacher" as EA
participant "CSI Volume Driver" as D


== 创建动态分配PVC ==
C -> A: watch PVC
A --> C: create PVC
C --> A: add annotation in PVC(storage-provisioner)
EP -> A: watch PVC注释的storage-provisioner字段
A --> EP
EP -> A: 获得Storageclass信息
A --> EP
EP -> D: call CreateVolume创建 volume
D --> EP: create success
EP -> A: create PV，bind to PVC

==Pod调度到Node后(Master) ==
C -> A: watch Pod
A -->C: Pod调度到Node
C -> P: call attach方法
P -> A: create VolumeAttachment(VA)
P -> A: watch VA's status
EA -> A: watch VA
A --> EA
EA -> D: call ControllerPublish
D --> EA: return success
EA -> A: update VA's status attached
A --> P: VA's attached == true
P --> C: update controller内部状态 

==Pod调度到Node后(Node)==
K -> A: watch Pod
A --> K: schedule CSI Pod to Node
K -> P: call WaitForAttach方法
P -> A: watch VA's attached字段 
A --> P: VA's attached == true
P --> K: return WaitForAttach 
K -> P: call MountDevice方法
P --> K: return
K -> P: call mount(setup)方法
P -> D: call NodePublishVolume
D --> P: return success mounted

== Pod删除后（Master）==
C -> A: watch Pod
A --> C: deleted/terminated Pod
C -> P: call detach method
P -> A: delete VA(set VA's deletionTimestamp)
EA -> A: watch VA
A --> EA: set VA's deletionTimestamp
EA -> D: call ControllerUnpublish
D --> EA: return success
EA -> A: remove VA's finalizer
P -> A: watch VA
A --> P: delete VA
P --> C: update controller-manager's state

== Pod删除后（Node） ==
K -> A: watch Pod
A --> K: deleted/terminated Pod
K -> P: call UnmountDevice
P --> K: return immediately
K -> P: call unmount(teardown)方法
P -> D: call NodeUnpublishVolume
D --> P: return success, unmounted from the container

== PVC删除后 ==
EP -> A: watch CSI PVC
A --> EP: delete CSI PVC
EP -> D: call DeleteVolume
note right: reclaim policy is delete
D --> EP: return success
EP -> A: delete PV
```
