## 1 gRPC 概念

### 1.1 总览
- gRPC 定义了可以远程调用的服务，默认使用 Protobuf 为 定义接口语言 （Interface Definition Language ，IDL)。
- 服务端实现 API， 客户端调用 API

### 1.2 认证
- 如何将 gRPC 认证机制与用户认证系统结合，如何使用特定语言的 gRPC 认证。
- 支持 SSL/TLS 认证和 基于 Token 的认证机制， 使用 Token 必须在 SSL/TLS 之上使用。OAuth2 token

### 1.3 认证 API
- 信道证书：SSL 证书
- 调用证书：ClientContext

### 1.4 客户端的 SSL/TLS 认证
将ChannelCredentials 和 CallCredentials这两个证书放在 CompositeChannelCredentials 里，可以创建新的 ChannelCredential。

用户可从SslCredentials and an AccessTokenCredentials创建一个 ChannelCredentials。
可以用 CompositeCallCredentials 组成独立的  CallCredentials 

### 1.5 出错模型

- 返回 错误码 和 出错信息

## 2 实践
### 2.1 准备环境
- Step1 安装 Go 1.6 以上版本

- Step2 安装 gRPC
  ```
  $ go get -u google.golang.org/grpc
  ```

- Step3 安装 Protocol Buffer v3

  [下载链接](https://github.com/protocolbuffers/protobuf/releases)

- Step4 安装 Go protoc 插件

  确保 $GOPATH/bin 在系统 PATH 中
  ```
  $ go get -u github.com/golang/protobuf/protoc-gen-go
  ```

### 2.2 开发流程

#### 2.2.1 生成 pb.go 文件
- Step1 编写 proto 文件

- Step2 编译 proto 文件生成 pb.go 文件

    ```
    protoc -I $SRC_DIR $SRC_DIR/time.proto --go_out=plugins=grpc:$DST_DIR
    ```

#### 2.2.2 服务端开发
- Step 1 实现 pb 里的 rpc 服务接口
- Step 2 服务端代码
  - Step 2.1 指定监听端口
    ```
    lis, err := net.Listen("tcp", fmt.Sprintf(":%d", *port))
    ```

  - Step 2.2 创建 gRPC 服务端
    ```
    grpc.NewServer()
    ```
  - Step 2.3 将实现的 rpc 服务注册到 gRPC 服务端中
    ```
    RegisterTimeServerServer(grpcServer, &TimeService{})
    ```
  - Step 2.4 将监听端口注册到 gRPC 服务端
    ```
    grpcServer.Serve(lis)
    ```
#### 2.2.3 客户端开发
- Step 1 创建一个 gRPC 通道，连接服务端

  可在此设置加密参数
    ```
    conn, err := grpc.Dial(*serverAddr)
    if err != nil {
        ...
    }
    defer conn.Close()
    ```
- Step 2 创建 gRPC 客户端

    ```
    client := pb.NewRouteGuideClient(conn)
    ```

- Step 3 调用 gRPC 方法

    ```
    feature, err := client.GetFeature(context.Background(), &pb.Point{409146138, -746188906})
    if err != nil {
            ...
    }
    ```

## 3 要点讨论

### 3.1 流处理

#### 3.1.1 服务端流

```
rect := &pb.Rectangle{ ... }  // initialize a pb.Rectangle

// NOTE: stream like a server
stream, err := client.ListFeatures(context.Background(), rect)
if err != nil {
    ...
}
for {

    // NOTE: get points from server
    feature, err := stream.Recv()
    if err == io.EOF {
        break
    }
    if err != nil {
        log.Fatalf("%v.ListFeatures(_) = _, %v", client, err)
    }
    log.Println(feature)
}
```

#### 3.1.2 客户端流
```
// Create a random number of random points
r := rand.New(rand.NewSource(time.Now().UnixNano()))
pointCount := int(r.Int31n(100)) + 2 // Traverse at least two points
var points []*pb.Point
for i := 0; i < pointCount; i++ {
	points = append(points, randomPoint(r))
}
log.Printf("Traversing %d points.", len(points))

// NOTE: stream like a server
stream, err := client.RecordRoute(context.Background())
if err != nil {
	log.Fatalf("%v.RecordRoute(_) = _, %v", client, err)
}

for _, point := range points {

    // NOTE: send points to server side
	if err := stream.Send(point); err != nil {
		log.Fatalf("%v.Send(%v) = %v", stream, point, err)
	}
}

// NOTE: get result from server
reply, err := stream.CloseAndRecv()
if err != nil {
	log.Fatalf("%v.CloseAndRecv() got error %v, want %v", stream, err, nil)
}
log.Printf("Route summary: %v", reply)
```
#### 3.1.3 双向流

```
stream, err := client.RouteChat(context.Background())
waitc := make(chan struct{})
go func() {
	for {
        // NOTE: read from server
		in, err := stream.Recv()
		if err == io.EOF {
			// read done.
			close(waitc)
			return
		}
		if err != nil {
			log.Fatalf("Failed to receive a note : %v", err)
		}
		log.Printf("Got message %s at point(%d, %d)", in.Message, in.Location.Latitude, in.Location.Longitude)
	}
}()
for _, note := range notes {
    // NOTE: send to server
	if err := stream.Send(note); err != nil {
		log.Fatalf("Failed to send a note: %v", err)
	}
}
stream.CloseSend()
<-waitc
```

> Q: waitc 通道作用？
    
    A: 由于是双向流，必须等 go routine 的接受流接收到服务端端开请求 EOF，客户端进程才能退出。
### 3.2 超时器

#### 3.2.1 服务端超时器

#### 3.2.2 客户端超时器

### 3.3 截断器

#### 3.3.1 开发者开发符合截断器签名的函数

一元服务端截断器函数签名
```
type UnaryServerInterceptor 
func(
    ctx context.Context, 
    req interface{}, 
    info *UnaryServerInfo, 
    handler UnaryHandler
    ) (resp interface{}, err error)
```

流服务端截断器函数签名
```
type StreamServerInterceptor 
func(
    srv interface{}, 
    ss ServerStream, 
    info *StreamServerInfo, 
    handler StreamHandler
    ) error
```

#### 3.3.2 gRPC帮助函数，从函数签名转换为 ServerOption 对象

生成 ServerOption
```
func UnaryInterceptor(i UnaryServerInterceptor) ServerOption
func StreamInterceptor(i StreamServerInterceptor) ServerOption
```

#### 3.3.3 创建服务端时填入 ServerOption，填入截断器函数信息
截断器选项从 ServerOption 里填入
```
grpc.NewServer(opt...ServerOption) *Server
```

### 3.4 异步

### 3.5 认证

### 3.6 单元测试

### 3.7 性能测试

- 介绍性能基准测试工具和场景，测试基础设施

## 4. 问题

1. enum 定义是否可以放在 message 定义外面？

    答：可以，You can define enums within a message definition, as in the above example, or outside – these enums can be reused in any message definition in your .proto file.  [link](https://developers.google.com/protocol-buffers/docs/proto#enum)

1. 是否必须实现所有grpc service方法？
    
    答：是，不然无法注册开发者实现的服务端 struct 到 grpc 服务端中。

1. UnaryInterceptor 在 stream rpc 中是否会失效？ 