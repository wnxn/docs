# 存储卷性能测试

## 调研

K8S 六种存储解决方案的性能比较测试（ https://mp.weixin.qq.com/s/bV9_KBaqe4XqUbd32w8CEw ），一文中使用 FIO 对磁盘性能进行测试，原始数据在 https://gist.github.com/pupapaik/76c5b7f124dbb69080840f01bf71f924 。

## 方案

使用 FIO 测试工具收集硬盘 IOPS 和 带宽 数据。FIO 的测试方案文件以 FIO 项目的例子（ https://github.com/axboe/fio/blob/master/examples/ssd-test.fio ）为基础，略加修改。
- 主机： ubuntu 16.04 8core8G
- 硬盘：云平台硬盘性能型，容量型，SSD企业型，基础型，NeonSAN，副本数均为多副本。硬盘容量 500 GB，文件系统 Ext4.
- 目的：测试容器内硬盘性能和云平台原生方法使用硬盘是否有性能上区别。
- 测试工具：Kubernetes v1.12, FIO 2.2.10，QingCloud CSI v0.2.1
- 测试内容：随机读测试，随机写测试，随机读写测试，顺序读测试，顺序写测试，顺序读写测试。数据包含 带宽 和 IOPS。

## 测试方法

### 准备硬盘

将硬盘以 Ext4 格式化并挂载至指定目录，如 /mnt/hp

### 安装 FIO
```
apt install fio
```

### 创建配置文件

```
vi ssd-test.fio
[global]
bs=4k
ioengine=libaio
iodepth=16
size=10g
direct=1
runtime=60
numjobs=4

[seq-read]
rw=read
stonewall

[rand-read]
rw=randread
stonewall

[seq-write]
rw=write
stonewall

[rand-write]
rw=randwrite
stonewall

[seq-rw]
rw=rw
stonewall

[rand-rw]
rw=randrw
stonewall
```

### 执行测试程序
```
fio ssd-test.fio -directory /mnt/hp -output ./hp.result
```
