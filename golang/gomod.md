# Go Modules 学习

## 创建 Go mod 新项目
### 初始化
> go.sum 保存 hash 值， go.mod 保存版本依赖信息
> 会自动将缓存下载至 $GOPATH/pkg/mod
```
go mod init github.com/yunify/xxx
```

## 日常使用
### 列出当前依赖
```
go list -m all
```

## 清理依赖
```
go mod tidy
go list -m all
```

### 按照版本添加依赖
1. 列出依赖版本
```
go list -m -versions rsc.io/sampler
```

1. 升级依赖 
```
go get rsc.io/sampler@v1.3.1
```

### 添加特定依赖
1. 修改 go.mod 文件

1. 下载依赖
```
go mod download
```

## 原则
### 增加新的主版本依赖
> 每个主版本在 GO mod 里是不同的引用路径，从 v2 开始必须在路径后加 v2


### 升级新的主版本依赖
> 改 import 里的引用路径即可
> 

### 不同的主版本依赖可以共存
例如 rsc.io/quote 库可以让 v1.x.x 和 v3.x.x 版本共存

```
$ go list -m rsc.io/q...
rsc.io/quote v1.5.2
rsc.io/quote/v3 v3.1.0
```

## 工作流程
1. go mod init 创建初始化项目
1. go build, go test 增加包依赖
1. go list -m all 打印 go mod 管理的所有依赖
1. go get 新增依赖/改变依赖版本
1. go mod tidy 移除无用的依赖

## 参考资料

- 使用 Go Modules: https://blog.golang.org/using-go-modules
- Modules 官方文档: https://github.com/golang/go/wiki/Modules