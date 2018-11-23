## csi_plugin.go

```
[T] csiPlugin: 
    [I] volume.VolumeHost
    [I] CSIDriverList
    [I] CSIDriverInformer
    [I]{AttachableVolumePlugin, BlockVolumePlugin, DeviceMountableVolumePlugin, VolumePlugin}(pkg/volume/plugins.go)
    [F]{Init}
[T] RegistrationHandle: 
    [I]{PluginHandler}(pkg/kubelet/util/pluginwatcher/types.go)
    [M]{ValidatePlugin,RegisterPlugin}

```

## csi_client.go

```
[I] csiClient:
    [M]NodeGetInfo
    [M]NodePublishVolume/NodeUnpublishVolume
    [M]NodeStageVolume/NodeUnstageVolume
    [M]NodeGetCapabilities
```

```
[T] csiDriverClient
    [T] driverName
    [T] nodeClientCreator
    [I] csiClient
```

## csi_attacher.go

```
[T] csiAttacher:
    [T] csiPlugin
    [T] kubernetes.Interface
    [T] csiClient
    [I] Attacher: create VA
    [I] Detacher: delete VA
    [I] DeviceMounter: [M] MountDevice: [M] GenerateMountVolumeFunc (operation_generator.go L519)
    [I] DeviceUnmounter
```

## csi_mounter.go

```
[T] csiMountMgr
    [I] MetricsProvider
    [I] Mounter: [M] SetUp(fsGroup), [M] SetUpAt(fsGroup)
    [I] Unmounter
    [I] Volume
```