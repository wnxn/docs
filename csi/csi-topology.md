# 实现拓扑功能

## 调研云平台可用区特性
- 可用区创建命令参数，与普通 zone 异同.
zone 填 pek3 默认创建到 pek3b，填 pek3c 创建到 pek3c
```
# qingcloud iaas create-volumes -s 10 -t 200 -z pek3c
{
  "action": "CreateVolumesResponse", 
  "job_id": "j-n3c0ox94zbe", 
  "volumes": [
    "vol-iyvr83mk"
  ], 
  "ret_code": 0
}

```

- 可用区查询硬盘
硬盘为 pek3c，zone 填 pek3 或 pek3c 可查询到，填 pek3b 不行
```
# qingcloud iaas describe-volumes -v vol-iyvr83mk -z pek3c
{
  "action": "DescribeVolumesResponse", 
  "total_count": 1, 
  "volume_set": [
    {
      "read_throughput": 0, 
      "extra": null, 
      "instances": [
        {
          "instance_id": "", 
          "instance_name": ""
        }
      ], 
      "iops": 2300, 
      "owner": "usr-XqlPq3qV", 
      "place_group_id": "plg-00000201", 
      "size": 10, 
      "sub_code": 0, 
      "instance": {
        "instance_id": "", 
        "instance_name": ""
      }, 
      "status_time": "2019-07-23T03:19:40Z", 
      "resources": [
        {
          "device": "", 
          "resource_name": "", 
          "resource_type": "instance", 
          "resource_id": ""
        }
      ], 
      "status": "available", 
      "description": null, 
      "tags": [], 
      "transition_status": "", 
      "repl": "rpp-00000000", 
      "volume_id": "vol-iyvr83mk", 
      "zone_id": "pek3c", 
      "lastest_snapshot_time": null, 
      "volume_type": 200, 
      "create_time": "2019-07-23T03:19:40Z", 
      "throughput": 136192, 
      "read_iops": 0, 
      "volume_name": "", 
      "resource_project_info": []
    }
  ], 
  "ret_code": 0
}

```

- A 可用区硬盘是否可以挂载至 B 可用区
    - 基础型，企业型，NeonSAN，容量型
    同 subzone 可以挂载，不同 subzone 不可挂载
    主机 pek3c，硬盘 pek3c 可以挂载
    主机 pek3c，硬盘 pek3b 不可挂载
    ```
    # qingcloud iaas attach-volumes -v vol-m1m19jq1 -i i-anqp0nl8
    {
    "message": "PermissionDenied, volume can not attach to instance in different zone", 
    "ret_code": 1400
    }
    ```

- A 可用区快照是否可以在 B 可用区创建硬盘
可以，快照无可用区区分
```
# qingcloud iaas describe-snapshots -n ss-8s3hc65p -z pek3d -V 1
{
  "action": "DescribeSnapshotsResponse", 
  "snapshot_set": [
    {
      "status": "available", 
      "head_chain": 1, 
      "snapshot_name": "csi", 
      "snapshot_id": "ss-8s3hc65p", 
      "owner": "usr-XqlPq3qV", 
      "description": null, 
      "total_size": 10240, 
      "sub_code": 0, 
      "tags": [], 
      "parent_id": "self", 
      "provider": "self", 
      "status_time": "2019-07-23T03:37:51Z", 
      "size": 10240, 
      "is_taken": 1, 
      "snapshot_time": "2019-07-23T03:36:49Z", 
      "root_id": "ss-8s3hc65p", 
      "snapshot_repl_info": {
        "pek3b": 1, 
        "pek3c": 1
      }, 
      "visibility": "private", 
      "virtual_size": 10240, 
      "resource": {
        "resource_name": "", 
        "resource_type": "volume", 
        "resource_id": "vol-kt125m7z"
      }, 
      "is_head": 1, 
      "lastest_snapshot_time": "2019-07-23T03:36:49Z", 
      "total_count": 1, 
      "snapshot_resource": {
        "architecture": "hp", 
        "volume_type": 200, 
        "size": 10
      }, 
      "snapshot_type": 1, 
      "create_time": "2019-07-23T03:37:51Z", 
      "resource_project_info": []
    }
  ], 
  "ret_code": 0, 
  "total_count": 1
}
```

- A 可用区硬盘是否可以克隆至 B 可用区
可以
## CSI 相关

### 接口
- CreateVolume
- GetCapacity
- NodeGetInfo
```
# qingcloud iaas describe-instances -i i-anqp0nl8 -V 1
{
  "action": "DescribeInstancesResponse", 
  "instance_set": [
    {
      "vxnets": [
        {
          "ipv6_address": "", 
          "vxnet_type": 1, 
          "vxnet_id": "vxnet-mws1ml6", 
          "vxnet_name": "kubesphere", 
          "role": 1, 
          "private_ip": "192.168.0.11", 
          "nic_id": "52:54:9e:fb:52:36"
        }
      ], 
      "keypair_ids": [], 
      "fence": null, 
      "extra": {
        "iops": 2600, 
        "nic_mqueue": 0, 
        "read_throughput": 0, 
        "ivshmem": [], 
        "gpu_pci_nums": "", 
        "cpu_max": 0, 
        "cpu_model": "", 
        "bandwidth": 2000, 
        "mem_max": 0, 
        "throughput": 141312, 
        "read_iops": 0, 
        "hypervisor": "kvm", 
        "gpu": 0, 
        "os_disk_size": 20, 
        "gpu_class": 0, 
        "features": 4
      }, 
      "image": {
        "ui_type": "tui", 
        "processor_type": "64bit", 
        "image_id": "xenial5x64b", 
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
        "image_name": "Ubuntu Server 16.04.5 LTS 64bit", 
        "platform": "linux", 
        "os_family": "ubuntu", 
        "image_size": 20, 
        "features": 0
      }, 
      "graphics_passwd": "0ApmMqYtENFT79kaaLlQOdM6VNotAwuu", 
      "dns_aliases": [], 
      "alarm_status": "", 
      "owner": "usr-XqlPq3qV", 
      "memory_current": 4096, 
      "vcpus_current": 4, 
      "instance_name": "csi-topology", 
      "sub_code": 0, 
      "graphics_protocol": "vnc", 
      "platform": "linux", 
      "instance_class": 201, 
      "status_time": "2019-07-23T03:10:04Z", 
      "status": "running", 
      "description": null, 
      "cpu_topology": "", 
      "tags": [], 
      "transition_status": "", 
      "eips": [], 
      "repl": "rpp-00000002", 
      "volume_ids": [], 
      "zone_id": "pek3c", 
      "lastest_snapshot_time": null, 
      "instance_group": null, 
      "instance_id": "i-anqp0nl8", 
      "instance_type": "e1.xlarge.r1", 
      "create_time": "2019-07-23T03:10:04Z", 
      "volumes": [], 
      "resource_project_info": []
    }
  ], 
  "ret_code": 0, 
  "total_count": 1
}
```

- 主机信息

```
# qingcloud iaas describe-instances -i i-n12e2tg0 -V 1
{
  "action": "DescribeInstancesResponse", 
  "instance_set": [
    {
      "host_machine": "ap2ar06n04", 
      "logic_volumes": [
        {
          "device": "vda1", 
          "volume_id": "os"
        }, 
        {
          "device": "vdc", 
          "volume_id": "vol-f9ufyizh"
        }, 
        {
          "device": "vdd", 
          "volume_id": "vol-s8nrjwj3"
        }, 
        {
          "device": "vda1", 
          "volume_id": "os"
        }, 
        {
          "device": "vdc", 
          "volume_id": "vol-f9ufyizh"
        }, 
        {
          "device": "vdd", 
          "volume_id": "vol-s8nrjwj3"
        }
      ], 
      "vxnets": [
        {
          "ipv6_address": "", 
          "vxnet_type": 1, 
          "vxnet_id": "vxnet-l3sl528", 
          "vxnet_name": "asia-0201", 
          "role": 1, 
          "private_ip": "192.168.1.8", 
          "nic_id": "52:54:22:e1:90:98"
        }
      ], 
      "memory_current": 16384, 
      "graphics_port": "5939", 
      "extra": {
        "nic_type": "", 
        "nic_mqueue": 0, 
        "read_throughput": 0, 
        "container_mode": null, 
        "bandwidth": 1200, 
        "filetransfer": 1, 
        "slots": {
          "d|vol-f9ufyizh": "s|0x0b", 
          "d|i-n12e2tg0": "s|0x07", 
          "i|52:54:22:e1:90:98": "s|0x03", 
          "d|vol-s8nrjwj3": "s|0x0c"
        }, 
        "block_bus": "", 
        "gpu_class": 0, 
        "features": 4, 
        "no_restrict": 0, 
        "usb": 1, 
        "ivshmem": [], 
        "gpu_pci_nums": "", 
        "label": null, 
        "clipboard": 1, 
        "gpu": 0, 
        "qxl_number": 0, 
        "cpu_max": 0, 
        "cpu_model": "", 
        "mem_max": 0, 
        "usbredir": 1, 
        "no_limit": 0, 
        "iops": 980, 
        "throughput": 46080, 
        "read_iops": 0, 
        "hypervisor": "kvm", 
        "os_disk_size": 60, 
        "boot_dev": "", 
        "usb3_bus": null
      }, 
      "vcpus_max": 8, 
      "image": {
        "f_resetpwd": 1, 
        "ui_type": "tui", 
        "processor_type": "64bit", 
        "platform": "linux", 
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
        "image_name": "CentOS 7.5 64bit", 
        "image_id": "centos75x64b", 
        "agent_type": "pitrix", 
        "features": 0, 
        "image_size": 20, 
        "os_family": "centos", 
        "default_passwd": "p12cHANgepwD", 
        "default_user": "root"
      }, 
      "graphics_passwd": "0OjEbqh7IjnzeeoG0dAQFtkpWcQL2GQv", 
      "console_id": "qingcloud", 
      "create_time": "2019-07-22T05:21:37Z", 
      "alarm_status": "", 
      "owner": "usr-kylwuKxL", 
      "place_group_id": "plg-00000101", 
      "memory_max": 16384, 
      "keypair_ids": [], 
      "vcpus_current": 8, 
      "instance_name": "k8s-1.15", 
      "fence": null, 
      "broker_port": null, 
      "sub_code": 0, 
      "hostname": "i-n12e2tg0", 
      "root_user_id": "usr-kylwuKxL", 
      "label": null, 
      "platform": "linux", 
      "instance_class": 101, 
      "status_time": "2019-07-22T05:21:37Z", 
      "status": "running", 
      "container_conf": {}, 
      "description": null, 
      "cpu_topology": "", 
      "tags": [], 
      "transition_status": "", 
      "eips": [], 
      "controller": "self", 
      "repl": "rpp-00000002", 
      "broker_host": null, 
      "volume_ids": [
        "vol-f9ufyizh", 
        "vol-s8nrjwj3"
      ], 
      "zone_id": "ap2a", 
      "lastest_snapshot_time": null, 
      "instance_group": null, 
      "instance_id": "i-n12e2tg0", 
      "instance_type": "s1.2xlarge.r2", 
      "graphics_protocol": "vnc", 
      "dns_aliases": [], 
      "volumes": [
        {
          "device": "/dev/vdc", 
          "volume_id": "vol-f9ufyizh"
        }, 
        {
          "device": "/dev/vdd", 
          "volume_id": "vol-s8nrjwj3"
        }
      ], 
      "resource_project_info": []
    }
  ], 
  "ret_code": 0, 
  "total_count": 1
}

```


### 插件权限字段
#### Plugin Cap
- VOLUME_ACCESSIBILOTY_CONSTRAINTS

### Feature Gate
- External-provisioner sidecar: --feature-gates=Topology=true 
- k8s core component:--feature-gates=CSINodeInfo=true

## K8s 适配

### 节点标签
```
beta.kubernetes.io/instance-type=n1-standard-1,
failure-domain.beta.kubernetes.io/region=us-central1,
failure-domain.beta.kubernetes.io/zone=us-central1-a,
kubernetes.io/hostname=kubernetes-master
```

### StorageClass

```
allowedTopologies:
- matchLabelExpressions:
  - key: failure-domain.beta.kubernetes.io/zone
    values:
    - us-central1-a
    - us-central1-b
```