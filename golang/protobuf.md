# 代码风格
1. Message 命名：驼峰命名法，首字母大写
1. 字段命名：小写，下划线分割单词
1. 枚举类型：全大写，下划线分割
1. Service 命名：驼峰命名法，首字母大写
1. GRPC 方法命名：驼峰命名法，首字母大写

# message编码
## 数字变长编码

最高位为标记位，1表示需读取后续 Byte，0表示结束读取。
解码将低7位合并，并且从最高位为0的Byte开始。
小端序排列

如： 70000 用 protobuf 编码后 
```
08 F0 A2 04

1111 0000 (F0)
1010 0010 (A2)
0000 0100 (04)
```

解码
```
111 0000
010 0010
000 0100

000 0100 010 0010 111 0000 
0001 0001 0001 0111 0000 (70000)
```

## 字符串编码

field number 和 类型 Byte | 字符串长度 Byte| 字符串值 

## 嵌套 message

field number 和 类型（2） Byte | 消息长度 Byte | 消息内容

# 设计技巧
- Protocol Buffer 没有定义消息长度，流传递多个消息时，约定消息长度
- 大于 1 MB 不要使用 Protobuf
- 自描述的 Message，需要语言平台支持 动态 Message （Dynamic message）
# Terminology
- binary wire format: 二进制连接格式