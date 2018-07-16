# neonsan
如何看image是否map
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

### umap volume

```
qbd -u csi/foo1
```

### delete 

```

```