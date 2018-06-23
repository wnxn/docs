## GlusterFS特性

### Volume Expansion
支持，并且无需删除当前pod即可扩容
```
[root@glusterfs-server1 ~]# gluster volume status vol_f7091c28431d45c508a9a2633db8fb5d detail
Status of volume: vol_f7091c28431d45c508a9a2633db8fb5d
------------------------------------------------------------------------------
Brick                : Brick 192.168.0.7:/var/lib/heketi/mounts/vg_30832fe2031b8580cff358309017abcb/brick_7da6bcdfae353fd65a298db751081b58/brick
TCP Port             : 49152               
RDMA Port            : 0                   
Online               : Y                   
Pid                  : 27805               
File System          : xfs                 
Device               : /dev/mapper/vg_30832fe2031b8580cff358309017abcb-brick_7da6bcdfae353fd65a298db751081b58
Mount Options        : rw,noatime,nouuid,attr2,inode64,logbsize=256k,sunit=512,swidth=512,noquota
Inode Size           : 512                 
Disk Space Free      : 529.2MB             
Total Disk Space     : 2.0GB               
Inode Count          : 1047552             
Free Inodes          : 1047480             
------------------------------------------------------------------------------
Brick                : Brick 192.168.0.6:/var/lib/heketi/mounts/vg_008d29a23472659717d37d9034557ac0/brick_e84c253f1e9e1e8f82bd304875d5be63/brick
TCP Port             : 49152               
RDMA Port            : 0                   
Online               : Y                   
Pid                  : 29245               
File System          : xfs                 
Device               : /dev/mapper/vg_008d29a23472659717d37d9034557ac0-brick_e84c253f1e9e1e8f82bd304875d5be63
Mount Options        : rw,noatime,nouuid,attr2,inode64,logbsize=256k,sunit=512,swidth=512,noquota
Inode Size           : 512                 
Disk Space Free      : 529.2MB             
Total Disk Space     : 2.0GB               
Inode Count          : 1047552             
Free Inodes          : 1047480             
------------------------------------------------------------------------------
Brick                : Brick 192.168.0.7:/var/lib/heketi/mounts/vg_30832fe2031b8580cff358309017abcb/brick_24048856d2f608e05345793ecf260cc1/brick
TCP Port             : 49153               
RDMA Port            : 0                   
Online               : Y                   
Pid                  : 28672               
File System          : xfs                 
Device               : /dev/mapper/vg_30832fe2031b8580cff358309017abcb-brick_24048856d2f608e05345793ecf260cc1
Mount Options        : rw,noatime,nouuid,attr2,inode64,logbsize=256k,sunit=512,swidth=512,noquota
Inode Size           : 512                 
Disk Space Free      : 16.0KB              
Total Disk Space     : 2.0GB               
Inode Count          : 544                 
Free Inodes          : 468                 
------------------------------------------------------------------------------
Brick                : Brick 192.168.0.6:/var/lib/heketi/mounts/vg_008d29a23472659717d37d9034557ac0/brick_862eedb7312cb557785e0705937dca73/brick
TCP Port             : 49153               
RDMA Port            : 0                   
Online               : Y                   
Pid                  : 340                 
File System          : xfs                 
Device               : /dev/mapper/vg_008d29a23472659717d37d9034557ac0-brick_862eedb7312cb557785e0705937dca73
Mount Options        : rw,noatime,nouuid,attr2,inode64,logbsize=256k,sunit=512,swidth=512,noquota
Inode Size           : 512                 
Disk Space Free      : 20.0KB              
Total Disk Space     : 2.0GB               
Inode Count          : 552                 
Free Inodes          : 476                 
------------------------------------------------------------------------------
Brick                : Brick 192.168.0.7:/var/lib/heketi/mounts/vg_30832fe2031b8580cff358309017abcb/brick_50abe5bcbe65d5c7b9e2d57d9d71d688/brick
TCP Port             : 49154               
RDMA Port            : 0                   
Online               : Y                   
Pid                  : 29486               
File System          : xfs                 
Device               : /dev/mapper/vg_30832fe2031b8580cff358309017abcb-brick_50abe5bcbe65d5c7b9e2d57d9d71d688
Mount Options        : rw,noatime,nouuid,attr2,inode64,logbsize=256k,sunit=512,swidth=512,noquota
Inode Size           : 512                 
Disk Space Free      : 6.0GB               
Total Disk Space     : 6.0GB               
Inode Count          : 3144704             
Free Inodes          : 3144678             
------------------------------------------------------------------------------
Brick                : Brick 192.168.0.6:/var/lib/heketi/mounts/vg_008d29a23472659717d37d9034557ac0/brick_5f86bfb5fe2edd294a8bdeccffda5df3/brick
TCP Port             : 49154               
RDMA Port            : 0                   
Online               : Y                   
Pid                  : 4477                
File System          : xfs                 
Device               : /dev/mapper/vg_008d29a23472659717d37d9034557ac0-brick_5f86bfb5fe2edd294a8bdeccffda5df3
Mount Options        : rw,noatime,nouuid,attr2,inode64,logbsize=256k,sunit=512,swidth=512,noquota
Inode Size           : 512                 
Disk Space Free      : 6.0GB               
Total Disk Space     : 6.0GB               
Inode Count          : 3144704             
Free Inodes          : 3144678             
```

### ReadWriteMany
支持

## 查看用量
```
[root@glusterfs-server1 ~]# gluster volume status vol_f7091c28431d45c508a9a2633db8fb5d detail
Status of volume: vol_f7091c28431d45c508a9a2633db8fb5d
------------------------------------------------------------------------------
Brick                : Brick 192.168.0.7:/var/lib/heketi/mounts/vg_30832fe2031b8580cff358309017abcb/brick_7da6bcdfae353fd65a298db751081b58/brick
TCP Port             : 49152               
RDMA Port            : 0                   
Online               : Y                   
Pid                  : 27805               
File System          : xfs                 
Device               : /dev/mapper/vg_30832fe2031b8580cff358309017abcb-brick_7da6bcdfae353fd65a298db751081b58
Mount Options        : rw,noatime,nouuid,attr2,inode64,logbsize=256k,sunit=512,swidth=512,noquota
Inode Size           : 512                 
Disk Space Free      : 2.0GB               
Total Disk Space     : 2.0GB               
Inode Count          : 1047552             
Free Inodes          : 1047525             
------------------------------------------------------------------------------
Brick                : Brick 192.168.0.6:/var/lib/heketi/mounts/vg_008d29a23472659717d37d9034557ac0/brick_e84c253f1e9e1e8f82bd304875d5be63/brick
TCP Port             : 49152               
RDMA Port            : 0                   
Online               : Y                   
Pid                  : 29245               
File System          : xfs                 
Device               : /dev/mapper/vg_008d29a23472659717d37d9034557ac0-brick_e84c253f1e9e1e8f82bd304875d5be63
Mount Options        : rw,noatime,nouuid,attr2,inode64,logbsize=256k,sunit=512,swidth=512,noquota
Inode Size           : 512                 
Disk Space Free      : 2.0GB               
Total Disk Space     : 2.0GB               
Inode Count          : 1047552             
Free Inodes          : 1047525             
...
```

## client安装
若无glusterfs命令，则安装
```
apt install glusterfs-client
```

## Ceph RBD特性

### Volume Expansion
已挂载至Pod的PVC，可以扩展，Pod中不可立即扩展，需要删除已有Pod，已有数据不会丢失

### ReadOnlyeMany
不支持，会报错
```
Events:
  Type     Reason                  Age               From                     Message
  ----     ------                  ----              ----                     -------
  Normal   Scheduled               10m               default-scheduler        Successfully assigned server-ceph-rox-6bdfb6fc6b-zpgr2 to i-qipv7cif
  Normal   SuccessfulAttachVolume  10m               attachdetach-controller  AttachVolume.Attach succeeded for volume "pvc-d129f819-7450-11e8-adc1-5254be97b24c"
  Normal   SuccessfulMountVolume   10m               kubelet, i-qipv7cif      MountVolume.SetUp succeeded for volume "default-token-b8blh"
  Warning  FailedMount             1m (x4 over 8m)   kubelet, i-qipv7cif      Unable to mount volumes for pod "server-ceph-rox-6bdfb6fc6b-zpgr2_default(e83e498c-7450-11e8-adc1-5254be97b24c)": timeout expired waiting for volumes to attach or mount for pod "default"/"server-ceph-rox-6bdfb6fc6b-zpgr2". list of unmounted volumes=[storage]. list of unattached volumes=[storage default-token-b8blh]
  Warning  FailedMount             42s (x9 over 9m)  kubelet, i-qipv7cif      MountVolume.WaitForAttach failed for volume "pvc-d129f819-7450-11e8-adc1-5254be97b24c" : rbd image rbd/kubernetes-dynamic-pvc-d12c9add-7450-11e8-b673-5254be97b24c is still being used

```

### 查看用量
rbd du ${IMAGE_NAME}
```
root@i-2ucr515s:~/storage/ceph# rbd du
warning: fast-diff map is not enabled for kubernetes-dynamic-pvc-3bf0386a-7430-11e8-b673-5254be97b24c. operation may be slow.
warning: fast-diff map is not enabled for kubernetes-dynamic-pvc-c530c7c0-7430-11e8-a969-5254739bd60e. operation may be slow.
warning: fast-diff map is not enabled for kubernetes-dynamic-pvc-d12c9add-7450-11e8-b673-5254be97b24c. operation may be slow.
NAME                                                        PROVISIONED   USED 
kubernetes-dynamic-pvc-3bf0386a-7430-11e8-b673-5254be97b24c      10240M 10104M 
kubernetes-dynamic-pvc-c530c7c0-7430-11e8-a969-5254739bd60e       5120M   176M 
kubernetes-dynamic-pvc-d12c9add-7450-11e8-b673-5254be97b24c       5120M   176M 
<TOTAL>                                                          20480M 10456M 

```

### client安装
若无rbd命令，则安装
```
apt install ceph-common
```

### rbd命令
将ceph rbd的`ceph.client.admin.keyring`和`ceph.conf`拷贝至/etc/ceph内

- check
    * version
    
    ```
    # rbd -v 
    ceph version 10.2.9
    ```

- create
    * create
    
    ```
    # rbd create cc2 --size 4096 --pool rbd --image-format=1 
    rbd: image format 1 is deprecated
    ```

    * check
    
    ```
    # rbd ls
    foo
    ```

- attach
    * attach
    
    ```
    # rbd map foo
    ```

    * check
    
    ```
    # fdisk -l
    ...

    Disk /dev/rbd0: 4 GiB, 4294967296 bytes, 8388608 sectors
    Units: sectors of 1 * 512 = 512 bytes
    Sector size (logical/physical): 512 bytes / 512 bytes
    I/O size (minimum/optimal): 4194304 bytes / 4194304 bytes
    ```

- mount
    * format rbd image
    
    ```
    # mkfs.ext4 -m0 /dev/rbd0
    mke2fs 1.42.13 (17-May-2015)
    Discarding device blocks: done                            
    Creating filesystem with 1048576 4k blocks and 262144 inodes
    Filesystem UUID: 4fa3e942-d6a2-49aa-8883-395d7676a2c4
    Superblock backups stored on blocks: 
        32768, 98304, 163840, 229376, 294912, 819200, 884736

    Allocating group tables: done                            
    Writing inode tables: done                            
    Creating journal (32768 blocks): done
    Writing superblocks and filesystem accounting information: done 

    ```

    * create mount dir
    
    ```
    # mkdir -p /mnt/rbd

    ```

    * mount rbd image
    
    ```
    # mount /dev/rbd0 /mnt/rbd
    ```

    * check
    
    ```
    # df -lh
    Filesystem      Size  Used Avail Use% Mounted on
    ...
    /dev/rbd0       3.9G  8.0M  3.8G   1% /mnt/rbd
    ```

- unmount
    * unmount
    
    ```
    # umount /mnt/rbd
    ```

    * check
    
    ```
    # df -lh
    Filesystem      Size  Used Avail Use% Mounted on
    ...
    ```

- detach
    * detach
    
    ```
    # rbd unmap foo
    ```

    * check
    
    ```
    # fdisk -l
    Disk /dev/vda: 20 GiB, 21474836480 bytes, 41943040 sectors
    Units: sectors of 1 * 512 = 512 bytes
    Sector size (logical/physical): 512 bytes / 512 bytes
    I/O size (minimum/optimal): 512 bytes / 512 bytes
    Disklabel type: dos
    Disk identifier: 0x5735896b

    Device     Boot Start      End  Sectors Size Id Type
    /dev/vda1  *     2048 41940991 41938944  20G 83 Linux


    Disk /dev/vdb: 1 GiB, 1073741824 bytes, 2097152 sectors
    Units: sectors of 1 * 512 = 512 bytes
    Sector size (logical/physical): 512 bytes / 512 bytes
    I/O size (minimum/optimal): 512 bytes / 512 bytes
    ```

- delete
```
# rbd remove foo
```




