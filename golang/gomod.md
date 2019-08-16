# Go Modules 学习

## 开始一个 Go mod 项目
1. 在仓库内任意目录写代码
1. 在仓库根目录执行 Go mod init {仓库 URL}
1. 在仓库路径内的包 import path 为 仓库 URL+仓库内路径名

> Go mod 会将缓存下载至 $GOPATH/pkg/mod

## 增加依赖
> 列出当前 go module （第一行）和依赖（后续行）： go list -m all
> go sum 保存 hash 值

## 升级依赖
1. 列出依赖版本
```
go list -m -versions rsc.io/sampler
```

1. 升级依赖 
```
go get rsc.io/sampler@v1.3.1
```

## 增加新的主版本依赖
> 每个主版本在 GO mod 里是不同的引用路径，从 v2 开始必须在路径后加 v2

## 升级新的主版本依赖
> 改 import 里的引用路径即可

## 清理依赖
```
go mod tidy
go list -m all
```

## 工作流程
1. go mod init 创建初始化项目
1. go build, go test 增加包依赖
1. go list -m all 打印 go mod 管理的所有依赖
1. go get 新增依赖/改变依赖版本
1. go mod tidy 移除无用的依赖

## 参考资料

- Using Go Modules: https://blog.golang.org/using-go-modules
- Modules: https://github.com/golang/go/wiki/Modules