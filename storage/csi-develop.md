# neonsan

## create volume

```
neonsan create_volume -volume csi/foo1 -size 2G -repcount 1
```

### list volume

```
neonsan list_volume -pool csi

```

### volume info

```
root@k8s:~# neonsan list_volume -pool csi -volume foo --detail
Volume Count:  1
+--------------+------+-------------+-----------+---------------+--------+---------------------+---------------------+
|      ID      | NAME |    SIZE     | REP COUNT | MIN REP COUNT | STATUS |     STATUS TIME     |    CREATED TIME     |
+--------------+------+-------------+-----------+---------------+--------+---------------------+---------------------+
| 251188477952 | foo  | 10737418240 |         1 |             1 | OK     | 2018-07-09 12:18:34 | 2018-07-09 12:18:34 |
+--------------+------+-------------+-----------+---------------+--------+---------------------+---------------------+
```

### map volume

```
qbd -m csi/foo1
```

### check map

```
# qbd -l
dev_id  vol_id  device  volume  config  read_bps    write_bps   read_iops   write_iops
0   0x3ff7000000    qbd0    csi/foo1    /etc/neonsan/qbd.conf   0   0   0   0
1   0x3a7c000000    qbd1    csi/foo /etc/neonsan/qbd.conf   0   0   0   0

```

### umap volume

```
qbd -u csi/foo1
```

### delete 

```

```
