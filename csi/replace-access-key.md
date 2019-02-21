# 目标

用新的 access key 替换旧的 access key

# 原料

新 Access Key
安装 QingCloud CSI 的 K8S 集群

# 步骤

## 编辑 QingCloud CSI 的 configmap

编辑  csi-qingcloud configmap 的 qy_access_key_id， qy_secret_access_key value 字段为新的 key id 和 secret

```
$ kubectl edit cm csi-qingcloud -n kube-system
...
    qy_access_key_id: 'NEW_ACCESS_KEY_ID'
    qy_secret_access_key: 'NEW_ACCESS_KEY_SECRET'
...
```

## 等待 CSI 相关 Pod 内更新 configmap（约 5 分钟）

## 查看 CSI 相关 Pod 内 configmap（包括 controller 和 node）
```
$ kubectl exec -ti csi-qingcloud-controller-0 -c csi-qingcloud -n kube-system -- cat /etc/config/config.yaml
...
qy_access_key_id: 'NEW_ACCESS_KEY_ID'
qy_secret_access_key: 'NEW_ACCESS_KEY_SECRET'
...
```

完成 Access Key 更新
