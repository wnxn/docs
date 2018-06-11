# Volumes概念

https://kubernetes.io/docs/concepts/storage/volumes/

## 背景
  - Docker的volume缺乏管理。
  - Kubernetes卷在跨容器重启时，里面数据有保留需求。
  - Pod不存在时，Volume也将不存在。
  - 一个Volume是个有数据的目录。
  - pod使用volume的配置项，spec.volumes, spec.containers.volumeMounts.
  - 容器内进程看到的文件系统视图是由Docker镜像和Volumes构成的。Docker镜像是文件系统层级的起源基础，并且任意的Volumes挂载在镜像内的指定路径内。Volumes不能挂载道其他Volumes或者包含指向其他Volumes的硬链接。Pod中的每个容器必须独立地指定所要挂载的Volume。

## Volume种类
* 网络数据卷
  - 可以在Pod中传递数据，某些种类网络数据卷可以被多个写者挂载
* configMap
* hostPath
   * 接触Docker内部文件`/var/lib/docker`
   * 容器内运行cAdvisor: `/sys`
   * 创建在底层宿主机的文件和目录仅仅能被root用户写。你可以在特权容器里以root用户运行进程或者修改宿主机的文件访问权限使得可以对hostPath卷执行写操作。
* emptyDir
  - 与Pod生命周期相关，与容器无关
  - 后端存储可以是SSD、网络存储或tmpfs
* local `v1.10 beta`
  - 对比hostPath，可以以一种持久的和便携的无需手工调度pod到node的方式使用local volumes。

## 存储插件
  - 包括CSI和FlexVolume，使得存储供应商创建定制的存储插件而不用将它们加入Kubernetes二进制中。
  - 可以独立于Kuberntes的代码开发，可作为扩展部分部署或安装在Kubernetes集群中。

### CSI `v1.10 beta`

#### 两篇资料
- Container Storage Interface（CSI）https://github.com/container-storage-interface/spec/blob/master/spec.md
- CSI设计意图
https://github.com/kubernetes/community/blob/master/contributors/design-proposals/storage/container-storage-interface.md


- CSI为容器编排系统定义一个标准接口，可将任意的存储系统暴露给容器。
- CSI卷不支持直接被Pod使用，仅仅可以通过PVC对象被Pod使用。
- 可以供存储管理员配置CSI PV的项：
- Controller Plugin & Node Plugin

####

|  字段     |  解释         | 接口      |
|------|----------|---------|
|`driver` | 卷驱动的名字|`GetPluginInfoResponse`        |
| `volumeHandle`   | 唯一指定卷的ID标识符，调用CSI卷驱动时需要传递  | `CreateVolumeResponse`      |
|`readOnly`   | 默认是false（可读写）  |passed to the CSI driver via the `readonly` field in the `ControllerPublishVolumeRequest`. |
|`fsType`   | 指定文件系统类型，并格式化，默认ext4  |  passed to the CSI driver via the `VolumeCapability` field of `ControllerPublishVolumeRequest`, `NodeStageVolumeRequest`, and `NodePublishVolumeRequest`. |
|`volumeAttributes`   | 一组字符串映射  | passed to the CSI driver via the `volume_attributes` field in the `ControllerPublishVolumeRequest`, `NodeStageVolumeRequest`, and `NodePublishVolumeRequest` |
| `controllerPublishSecretRef`（可选）  | 引用秘密信息对象，实现CSI的`ControllerPublishVolume`和`ControllerUnpublishVolume`调用  |   |
|`nodeStageSecretRef`（可选）   |引用秘密信息对象，实现`NodeStageVolume`调用   |   |
|`nodePublishSecretRef`（可选）   | 引用秘密信息对象，实现`NodePublishVolume`调用  |   |

### FlexVolume
- exec-based model

## 挂载传播 `v1.10 beta`
- 同一Pod内容器之间可以分享挂载的卷，甚至同一node的Pod之间可以分享。

# 延伸阅读
1. Container Storage Interface (CSI)定义
 https://github.com/container-storage-interface/spec/blob/master/spec.md
- 存储提供商创建一个存储插件
 https://github.com/kubernetes/community/blob/master/sig-storage/volume-plugin-faq.md
- CSI设计意图
https://github.com/kubernetes/community/blob/master/contributors/design-proposals/storage/container-storage-interface.md
- Flexvolume
https://github.com/kubernetes/community/blob/master/contributors/devel/flexvolume.md
- CSI帮助项目
https://github.com/rexray/gocsi
