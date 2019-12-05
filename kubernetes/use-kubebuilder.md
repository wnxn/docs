# 使用 Kubebuilder



### 初始化项目
```
go mod init tutorial.kubebuilder.io
kubebuilder init --domain tutorial.kubebuilder.io
```

### 增加 API
```
kubebuilder create api --group batch --version v1 --kind CronJob
```

在 api/v1/cronjob_types.go 文件处增加定义
通过 [controller-tools](https://github.com/kubernetes-sigs/controller-tools) 增加 YAML 文件

> 示例： https://github.com/kubernetes-sigs/kubebuilder/blob/master/docs/book/src/cronjob-tutorial/testdata/project/controllers/cronjob_controller.go
### 增加 RBAC 权限
```
// +kubebuilder:rbac:groups=batch.tutorial.kubebuilder.io,resources=cronjobs,verbs=get;list;watch;create;update;patch;delete
// +kubebuilder:rbac:groups=batch.tutorial.kubebuilder.io,resources=cronjobs/status,verbs=get;update;patch
```

1. load our cronjob
2. 记录已调度的 cronjob
3. 清理历史记录