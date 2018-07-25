# Neonsan

## create volume

- success
```
$ neonsan create_volume -volume foo3 -pool csi -size 1G -repcount 1
INFO[0000] create volume succeed.     
```

> success return 0

- failed

```
$ neonsan create_volume -volume foo3 -pool csi -size 1 -repcount 1
INFO[0000] Size must be based on multiples of 1G    
```

```
$ neonsan create_volume -volume foo3 -pool -size 1G -repcount 2
INFO[0000] create volume failed. Reason:HTTP status:400  rc:-1 reason:No enough store, replica count is:2 

```

```
$ neonsan create_volume -volume foo3 -pool -size 1G -repcount 1
INFO[0000] create volume failed. Reason:HTTP status:400  rc:-101 reason:Volume already existed
 
```

> error return 1

## delete volume

- success
```
$ neonsan delete_volume -pool csi -volume foo3
delete volume succeed.
```
> return: 0
- failed
```
# neonsan delete_volume -pool csi -volume foo
FATA[0000] Failed to delete volume:foo, reason:HTTP status:400  rc:-1 reason:Volume is opened 
```
> return: 1

> return 0


- failed

```
$ neonsan delete_volume -volume 305563435008 -pool csi
FATA[0000] Failed to delete volume:305563435008, reason:HTTP status:400  rc:-102 reason:Volume not exists 
```

> return 1

## list volumes

- success
```
$ neonsan list_volume -pool csi
Volume Count:  3
+------+
| NAME |
+------+
| foo  |
| foo2 |
| foo1 |
+------+
```
> return: 0

- failed

```
neonsan list_volume
ERRO[0000] pool name is empty, please use a valid pool name. 
```

> return: 130

## volume info

```
root@k8s:~# neonsan list_volume -pool csi -volume foo --detail
Volume Count:  1
+--------------+------+-------------+-----------+---------------+--------+---------------------+---------------------+
|      ID      | NAME |    SIZE     | REP COUNT | MIN REP COUNT | STATUS |     STATUS TIME     |    CREATED TIME     |
+--------------+------+-------------+-----------+---------------+--------+---------------------+---------------------+
| 251188477952 | foo  | 10737418240 |         1 |             1 | OK     | 2018-07-09 12:18:34 | 2018-07-09 12:18:34 |
+--------------+------+-------------+-----------+---------------+--------+---------------------+---------------------+
```

## pool info

```
$ neonsan stats_pool --pool csi
+----------+-----------+-------+------+------+
| POOL ID  | POOL NAME | TOTAL | FREE | USED |
+----------+-----------+-------+------+------+
| 67108864 | csi       |  2982 | 1222 | 1759 |
+----------+-----------+-------+------+------+
```

> return: 0

# qbd

## attach volume
- success

```
# qbd -m csi/foo
[INFO 2018-07-25 19:04:23]volume->io_timeout:30, volume->conn_timeout:8(/z0/liuying/qfa/common/src/neon_client_common.c:258)
[INFO 2018-07-25 19:04:23]open volume timeout set to: 180(/z0/liuying/qfa/common/src/neon_client_common.c:894)
[INFO 2018-07-25 19:04:23]Connecting to zk server 172.31.30.12:2181, state:999 ...(/z0/liuying/qfa/common/src/neon_client_common.c:198)
[INFO 2018-07-25 19:04:24]Get master qfcenter IP:172.31.30.12(/z0/liuying/qfa/common/src/neon_client_common.c:246)
[DEBU 2018-07-25 19:04:24]Query http://172.31.30.12:2600/qfa?op=open_volume&name=csi%2Ffoo ...(/z0/liuying/qfa/common/src/neon_client_common.c:905)
root@k8s:~# echo $?
0
```

> return: 0

## detach volume
- success

```
# qbd -u csi/foo2
```
> return: 0

- failed
```
// resend detach request
root@k8s:~# qbd -u csi/foo
failed to ioctl /dev/qbdctl with QBD_IOC_UNMAP_VOLUME:25
unmap csi/foo failed
root@k8s:~# echo $?
25
```
> return: 25

```
// volume has been mounted
# qbd -u csi/foo
failed to ioctl /dev/qbdctl with QBD_IOC_UNMAP_VOLUME:16
```
>return: 130


### list attached volume

```
# qbd -l
dev_id  vol_id  device  volume  config  read_bps    write_bps   read_iops   write_iops
0   0x3ff7000000    qbd0    csi/foo1    /etc/neonsan/qbd.conf   0   0   0   0
1   0x3a7c000000    qbd1    csi/foo /etc/neonsan/qbd.conf   0   0   0   0

```

# Deploy

```
dpkg -i pitrix-libneonsan-dev-1.1.0.0.0.1.deb
dpkg -i pitrix-libneonsan-1.1.0.0.0.1.deb
dpkg -i pitrix-dep-qbd-1.1.0.amd64.deb
```

```
$ sudo cp librdmacm.so.1 /usr/lib
$ sudo cp libibverbs.so.1 /usr/lib
$ sudo cp libnl.so.1 /usr/lib/
```