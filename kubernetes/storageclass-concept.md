# Storage classes

## 资源对象

- 管理员定义对象，包含provisioner，parameters，reclaimPolicy（Delete，Retain），Mount Options字段
- 对象一旦创建，不可以再更新
- provisioner：声明使用的volume plugin，可以使用kubernetes内置的卷插件，也可以使用外部的供应商，外部供应商的卷插件应遵循[1]的规定
- reclaim policy: 回收策略，Delete（默认）或Retain，由StorageClass动态创建的PV具有与StorageClass一致的回收策略。
- mountOptions：由StorageClass动态创建的PV将会有与StorageClass相同的～字段，如果volume plugin不支持～，而StorageClass有～，那么创建PV失败。
- Parameters：与具体的volume plugin要求有关。
- pv,storageclass无namespace属性，PVC,ssecret有namespace属性

## 资源分配过程
### 静态分配
```
用户创建Pod ---> Pod Volume字段挂载PVC ---> 集群找寻合适PV与PVC对应  ----> 挂载到Pod使用
                                                 |                          /.\
                                                \!/                          |
                                           管理员手动申请存储 ------>  管理员手动创建PV
```

### 动态分配
```
用户创建Pod -----> Pod Volume字段挂载PVC ---->  PVC中storageClassName    ------> 挂载到Pod使用
              （claimName prometheus-pvc）       （qingcloud-storageclass）         /.\
                                                      |                             |
                                                     \!/                            |
                管理员创建StorageClass ------->   自动申请存储   -------------->  自动创建PV
```

# 参考文献
1. 外部存储提供商实现卷插件规范[https://github.com/kubernetes/community/blob/master/contributors/design-proposals/storage/volume-provisioning.md]
2. 外部存储实现卷插件例子[https://github.com/kubernetes-incubator/external-storage]
