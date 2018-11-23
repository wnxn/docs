
## Access Mode
RWX:        MULTI_NODE_MULTI_WRITER 5
RWO,ROX:    MULTI_NODE_SINGLE_WRITER 4
RWO:        SINGLE_NODE_WRITER 1
ROX:        MULTI_NODE_READER_ONLY 3

- Will a PVC with ROX or RWO access mode be bounded to a RWX PV?
No, a RWX PV can not be bounded to a ROX or RWO PVC.
a RWX PV can be bounded to a RWX PVC.

## Smoketest
* [ ] Create a RWO PVC which name is pvc-rwo-1 size 20G
* [ ] Create a deployment which mount pvc-rwo-1 at mnt directory
* [ ] Write a file in mnt directory
* [ ] Scale down deployment replication from 1 to 0
* [ ] Scale up deployment replication from 0 to 1
* [ ] Read and write the file in mnt directory
* [ ] Scale up deployment replications from 1 to 5
* [ ] Read and write the file in mnt directory
* [ ] Scale down deployment replications from 5 to 3
* [ ] Scale down deployment replications from 3 to 1
* [ ] resize pvc to 30G
* [ ] check Pod
* [ ] resize pvc to 15G
* [ ] check Pod
* [ ] If the pod scheduled to another node, read and write the file in mnt directory
* [ ] Delete the deployment
* [ ] Set spec.volume.persistentVolumeClaims.readOnly or  spec.containers.volumeMount.readOnly equal to true in deployment.
* [ ] Expect the file only readable in mnt directory
* [ ] Delete the pvc-rwo-1 PVC
* [ ] Create a RWX PVC which name is pvc-rwx-1, expect creating failed
* [ ] Create a ROX PVC which name is pvc-rox-1, expect creating failed


## TestBindMount
```
var targetPath = "/mnt"

func isNotDirErr(err error) bool {
    if e, ok := err.(*os.PathError); ok && e.Err == syscall.ENOTDIR {
        return true
    }
    return false
}

func TestBindMount(t *testing.T) {
    // 1. Mount
    // check targetPath is mounted
    notMnt, err := mount.New("").IsLikelyNotMountPoint(targetPath)
    //  notMnt, err := mount.New("").IsNotMountPoint(targetPath)
    flag := isNotDirErr(err)
    t.Logf("%v |%v |%v", notMnt, err, flag)

    if err != nil {
        if os.IsNotExist(err) {
            if err = os.MkdirAll(targetPath, 0750); err != nil {
                t.Error(err.Error())
            }
            notMnt = true
        } else {
            t.Error(codes.Internal, err.Error())
        }
    }
    if !notMnt {
        t.Logf("%s %v", targetPath, notMnt)
    }
}
```

## TestCsiCreateVolume
```
package block

import "testing"
import (
    "flag"
    "github.com/container-storage-interface/spec/lib/go/csi/v0"
    "github.com/kubernetes-csi/drivers/pkg/csi-common"
    "golang.org/x/net/context"
)

func TestCsiCreateVolume(t *testing.T) {
    flag.Set("alsologtostderr", "true")
    flag.Set("log_dir", "/tmp")
    flag.Set("v", "3")
    flag.Parse()

    drv := csicommon.NewCSIDriver("fake", "fake", "fake")
    cs := controllerServer{csicommon.NewDefaultControllerServer(drv)}
    req := csi.CreateVolumeRequest{}
    req.Name = "wx-sanity"
    req.VolumeCapabilities = []*csi.VolumeCapability{
        {nil, &csi.VolumeCapability_AccessMode{csi.VolumeCapability_AccessMode_MULTI_NODE_MULTI_WRITER}},
    }
    req.CapacityRange = &csi.CapacityRange{1 * gib, 0}
    cs.Driver.AddControllerServiceCapabilities([]csi.ControllerServiceCapability_RPC_Type{
        csi.ControllerServiceCapability_RPC_CREATE_DELETE_VOLUME,
        csi.ControllerServiceCapability_RPC_PUBLISH_UNPUBLISH_VOLUME})
    cs.Driver.AddVolumeCapabilityAccessModes([]csi.VolumeCapability_AccessMode_Mode{
        csi.VolumeCapability_AccessMode_MULTI_NODE_MULTI_WRITER})
    _, err := cs.CreateVolume(context.Background(), &req)

    if err != nil {
        t.Errorf(err.Error())
    } else {
        t.Logf("Pass")
    }
}
```