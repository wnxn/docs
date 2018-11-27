# QingCloud Block Volume Usage
## Create
### Command

```
root@dev:~/.qingcloud# qingcloud iaas create-volumes -z ap2a -s 50 -t 0 -c 1 -N test-snap
{
"action": "CreateVolumesResponse", 
"job_id": "j-gs6fbr9tfpd", 
"volumes": [
    "vol-df3m8oal"
], 
"ret_code": 0
}
root@dev:~/.qingcloud# echo $?
0
```

## Delete

### Command
root@dev:~# qingcloud iaas delete-volumes -z ap2a -v vol-o2pgphwn
{
  "action": "DeleteVolumesResponse", 
  "job_id": "j-7r8wh1kkluq", 
  "ret_code": 0
}

## Attach

### Command

```
root@dev:~/.qingcloud# qingcloud iaas attach-volumes -z ap2a -i i-8ovc23m0 -v vol-df3m8oal
{
  "action": "AttachVolumesResponse", 
  "job_id": "j-ebk6wu2xk09", 
  "ret_code": 0
}
root@dev:~/.qingcloud# echo $?
0
```

### Volume Info
```
root@dev:~/.qingcloud# qingcloud iaas describe-volumes -z ap2a -v vol-df3m8oal
{
  "action": "DescribeVolumesResponse", 
  "total_count": 1, 
  "volume_set": [
    {
      "status": "in-use", 
      "resources": [
        {
          "device": "/dev/vdc", 
          "resource_name": "dev", 
          "resource_type": "instance", 
          "resource_id": "i-8ovc23m0"
        }
      ], 
      "zone_id": "ap2a", 
      "volume_id": "vol-df3m8oal", 
      "instance": {
        "instance_id": "i-8ovc23m0", 
        "instance_name": "dev", 
        "device": "/dev/vdc"
      }, 
      "lastest_snapshot_time": null, 
      "sub_code": 0, 
      "transition_status": "", 
      "volume_type": 0, 
      "status_time": "2018-11-27T10:00:12Z", 
      "instances": [
        {
          "instance_id": "i-8ovc23m0", 
          "instance_name": "dev", 
          "device": "/dev/vdc"
        }
      ], 
      "repl": "rpp-00000000", 
      "create_time": "2018-11-27T09:43:31Z", 
      "extra": null, 
      "volume_name": "test-snap", 
      "owner": "usr-kylwuKxL", 
      "place_group_id": "plg-00000000", 
      "size": 50, 
      "resource_project_info": [], 
      "tags": [], 
      "description": null
    }
  ], 
  "ret_code": 0
}
```

### Instance Info
```
root@dev:~/.qingcloud# qingcloud iaas describe-instances -z ap2a -i i-8ovc23m0 
{
  "action": "DescribeInstancesResponse", 
  "instance_set": [
    {
      "vxnets": [
        {
          "ipv6_address": "", 
          "vxnet_type": 1, 
          "vxnet_id": "vxnet-l3sl528", 
          "vxnet_name": "asia-0201", 
          "role": 1, 
          "private_ip": "192.168.1.2", 
          "nic_id": "52:54:9f:cd:6d:dc"
        }
      ], 
      "memory_current": 8192, 
      "extra": {
        "nic_mqueue": 0, 
        "ivshmem": [], 
        "gpu_pci_nums": "", 
        "cpu_max": 0, 
        "cpu_model": "", 
        "mem_max": 0, 
        "hypervisor": "kvm", 
        "gpu": 0, 
        "os_disk_size": 70, 
        "gpu_class": 0, 
        "features": 4
      }, 
      "image": {
        "ui_type": "tui", 
        "processor_type": "64bit", 
        "image_id": "xenial4x64a", 
        "features_supported": {
          "set_keypair": 1, 
          "disk_hot_plug": 1, 
          "user_data": 1, 
          "set_pwd": 1, 
          "join_multiple_managed_vxnets": 0, 
          "root_fs_rw_online": 1, 
          "nic_hot_plug": 1, 
          "root_fs_rw_offline": 1, 
          "reset_fstab": 1
        }, 
        "provider": "system", 
        "image_name": "Ubuntu Server 16.04.4 LTS 64bit", 
        "platform": "linux", 
        "os_family": "ubuntu", 
        "image_size": 20, 
        "features": 0
      }, 
      "graphics_passwd": "H5blNuzzv782KkGsJiy6UDsf9FDQqRNs", 
      "dns_aliases": [], 
      "alarm_status": "", 
      "owner": "usr-kylwuKxL", 
      "vcpus_current": 8, 
      "instance_name": "dev", 
      "sub_code": 0, 
      "graphics_protocol": "vnc", 
      "platform": "linux", 
      "instance_class": 0, 
      "status_time": "2018-11-26T06:13:20Z", 
      "status": "running", 
      "description": null, 
      "cpu_topology": "", 
      "tags": [], 
      "transition_status": "", 
      "eips": [], 
      "repl": "rpp-00000002", 
      "volume_ids": [
        "vol-df3m8oal"
      ], 
      "zone_id": "ap2a", 
      "lastest_snapshot_time": null, 
      "instance_id": "i-8ovc23m0", 
      "instance_type": "custom", 
      "create_time": "2018-11-26T06:13:20Z", 
      "volumes": [
        {
          "device": "/dev/vdc", 
          "volume_id": "vol-df3m8oal"
        }
      ], 
      "resource_project_info": []
    }
  ], 
  "ret_code": 0, 
  "total_count": 1
}
```

## Detach
### Command
```
root@dev:~/.qingcloud# qingcloud iaas detach-volumes -z ap2a -i i-8ovc23m0 -v vol-df3m8oal
{
  "action": "DetachVolumesResponse", 
  "job_id": "j-6462v3fz7k0", 
  "ret_code": 0
}
root@dev:~/.qingcloud# echo $?
0
```

### Volume Info
```
root@dev:~/.qingcloud# qingcloud iaas describe-volumes -z ap2a -v vol-df3m8oal
{
  "action": "DescribeVolumesResponse", 
  "total_count": 1, 
  "volume_set": [
    {
      "status": "available", 
      "resources": [
        {
          "device": "", 
          "resource_name": "", 
          "resource_type": "instance", 
          "resource_id": ""
        }
      ], 
      "zone_id": "ap2a", 
      "volume_id": "vol-df3m8oal", 
      "instance": {
        "instance_id": "", 
        "instance_name": ""
      }, 
      "lastest_snapshot_time": null, 
      "sub_code": 0, 
      "transition_status": "", 
      "volume_type": 0, 
      "status_time": "2018-11-27T09:53:07Z", 
      "instances": [
        {
          "instance_id": "", 
          "instance_name": ""
        }
      ], 
      "repl": "rpp-00000000", 
      "create_time": "2018-11-27T09:43:31Z", 
      "extra": null, 
      "volume_name": "test-snap", 
      "owner": "usr-kylwuKxL", 
      "place_group_id": "plg-00000000", 
      "size": 50, 
      "resource_project_info": [], 
      "tags": [], 
      "description": null
    }
  ], 
  "ret_code": 0
}
root@dev:~/.qingcloud# echo $?
0
```

### Instance Info
```
root@dev:~/.qingcloud# qingcloud iaas describe-instances -z ap2a -i i-8ovc23m0 
{
  "action": "DescribeInstancesResponse", 
  "instance_set": [
    {
      "vxnets": [
        {
          "ipv6_address": "", 
          "vxnet_type": 1, 
          "vxnet_id": "vxnet-l3sl528", 
          "vxnet_name": "asia-0201", 
          "role": 1, 
          "private_ip": "192.168.1.2", 
          "nic_id": "52:54:9f:cd:6d:dc"
        }
      ], 
      "memory_current": 8192, 
      "extra": {
        "nic_mqueue": 0, 
        "ivshmem": [], 
        "gpu_pci_nums": "", 
        "cpu_max": 0, 
        "cpu_model": "", 
        "mem_max": 0, 
        "hypervisor": "kvm", 
        "gpu": 0, 
        "os_disk_size": 70, 
        "gpu_class": 0, 
        "features": 4
      }, 
      "image": {
        "ui_type": "tui", 
        "processor_type": "64bit", 
        "image_id": "xenial4x64a", 
        "features_supported": {
          "set_keypair": 1, 
          "disk_hot_plug": 1, 
          "user_data": 1, 
          "set_pwd": 1, 
          "join_multiple_managed_vxnets": 0, 
          "root_fs_rw_online": 1, 
          "nic_hot_plug": 1, 
          "root_fs_rw_offline": 1, 
          "reset_fstab": 1
        }, 
        "provider": "system", 
        "image_name": "Ubuntu Server 16.04.4 LTS 64bit", 
        "platform": "linux", 
        "os_family": "ubuntu", 
        "image_size": 20, 
        "features": 0
      }, 
      "graphics_passwd": "H5blNuzzv782KkGsJiy6UDsf9FDQqRNs", 
      "dns_aliases": [], 
      "alarm_status": "", 
      "owner": "usr-kylwuKxL", 
      "vcpus_current": 8, 
      "instance_name": "dev", 
      "sub_code": 0, 
      "graphics_protocol": "vnc", 
      "platform": "linux", 
      "instance_class": 0, 
      "status_time": "2018-11-26T06:13:20Z", 
      "status": "running", 
      "description": null, 
      "cpu_topology": "", 
      "tags": [], 
      "transition_status": "", 
      "eips": [], 
      "repl": "rpp-00000002", 
      "volume_ids": [], 
      "zone_id": "ap2a", 
      "lastest_snapshot_time": null, 
      "instance_id": "i-8ovc23m0", 
      "instance_type": "custom", 
      "create_time": "2018-11-26T06:13:20Z", 
      "volumes": [], 
      "resource_project_info": []
    }
  ], 
  "ret_code": 0, 
  "total_count": 1
}
root@dev:~/.qingcloud# echo $?
0
```

## Store data

### Partition
```
fdisk -l
```

```
parted /dev/vdc
mklabel gpt
mkpart primary 0 -1
print
```
### Format

```
mkfs.ext4 /dev/vdc

```
### Mount

```
mount /dev/vdc /mnt
```

## Resize volume

### Command

> Volume MUST be detached before resizing volume.
```
root@dev:/# qingcloud iaas resize-volumes -z ap2a -v vol-563pf22h -s 60
{
  "action": "ResizeVolumesResponse", 
  "job_id": "j-0ednbn5zsha", 
  "ret_code": 0
}
```

### Expand Filesystem

> Volume MUST be unmounted before expanding filesystem.

```
root@dev:/# e2fsck -f /dev/vdc
e2fsck 1.42.13 (17-May-2015)
Pass 1: Checking inodes, blocks, and sizes
Pass 2: Checking directory structure
Pass 3: Checking directory connectivity
Pass 4: Checking reference counts
Pass 5: Checking group summary information
/dev/vdc: 35/3276800 files (0.0% non-contiguous), 5857780/13107200 blocks
```

```
root@dev:/# resize2fs /dev/vdc
resize2fs 1.42.13 (17-May-2015)
Resizing the filesystem on /dev/vdc to 15728640 (4k) blocks.
The filesystem on /dev/vdc is now 15728640 (4k) blocks long.
```