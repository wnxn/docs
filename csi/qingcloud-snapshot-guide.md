# QingCloud Snapshot Usage

## Create Snapshot
### Command
```
root@dev:/mnt# qingcloud iaas create-snapshots -z ap2a -r vol-df3m8oal -F 1 -N full-snap
{
  "action": "CreateSnapshotsResponse", 
  "job_id": "j-9ebq2zp5sm3", 
  "snapshots": [
    "ss-umocjmc3"
  ], 
  "ret_code": 0
}
root@dev:/mnt# echo $?
0
```

### Snapshot Status

```
root@dev:~# qingcloud iaas describe-snapshots -z ap2a -n ss-umocjmc3
{
  "action": "DescribeSnapshotsResponse", 
  "snapshot_set": [
    {
      "status": "available", 
      "head_chain": 0, 
      "snapshot_name": "full-snap", 
      "snapshot_id": "ss-umocjmc3", 
      "owner": "usr-kylwuKxL", 
      "description": null, 
      "total_size": 51200, 
      "sub_code": 0, 
      "tags": [], 
      "parent_id": "self", 
      "provider": "self", 
      "status_time": "2018-11-27T10:36:16Z", 
      "size": 51200, 
      "is_taken": 1, 
      "snapshot_time": "2018-11-27T10:31:54Z", 
      "root_id": "ss-umocjmc3", 
      "visibility": "private", 
      "virtual_size": 51200, 
      "resource": {
        "resource_name": "test-snap", 
        "resource_type": "volume", 
        "resource_id": "vol-df3m8oal"
      }, 
      "is_head": 0, 
      "lastest_snapshot_time": "2018-11-27T10:31:54Z", 
      "total_count": 1, 
      "snapshot_type": 1, 
      "create_time": "2018-11-27T10:36:16Z", 
      "resource_project_info": []
    }
  ], 
  "ret_code": 0, 
  "total_count": 1
}
root@dev:~# echo $?
0

```

## Restore Volume from Snapshot

### Command
```
root@dev:~# qingcloud iaas create-volume-from-snapshot -z ap2a -s ss-umocjmc3 -N restore-2
{
  "action": "CreateVolumeFromSnapshotResponse", 
  "ret_code": 0, 
  "job_id": "j-if98xpeeu01", 
  "volume_id": "vol-kihuzzei"
}
```

### Volume Status

```
root@dev:~# qingcloud iaas describe-volumes -z ap2a -v vol-kihuzzei
{
  "action": "DescribeVolumesResponse", 
  "total_count": 1, 
  "volume_set": [
    {
      "status": "pending", 
      "resources": [
        {
          "device": "", 
          "resource_name": "", 
          "resource_type": "instance", 
          "resource_id": ""
        }
      ], 
      "zone_id": "ap2a", 
      "volume_id": "vol-kihuzzei", 
      "instance": {
        "instance_id": "", 
        "instance_name": ""
      }, 
      "lastest_snapshot_time": null, 
      "sub_code": 0, 
      "transition_status": "creating", 
      "volume_type": 0, 
      "status_time": "2018-11-27T11:24:17Z", 
      "instances": [
        {
          "instance_id": "", 
          "instance_name": ""
        }
      ], 
      "repl": "rpp-00000000", 
      "create_time": "2018-11-27T11:24:17Z", 
      "extra": null, 
      "volume_name": "restore-2", 
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

## Delete Snapshot

### Command

```
root@dev:~# qingcloud iaas delete-snapshots -z ap2a -s ss-umocjmc3
{
  "action": "DeleteSnapshotsResponse", 
  "job_id": "j-dsup4vvhgiq", 
  "ret_code": 0
}
```