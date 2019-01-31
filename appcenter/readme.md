# 如何制作 KubeSphere APP

## 1 制作 APP 流程

1. 制作 KVM 镜像，image 内脚本安装依赖，将 confd 内容拷贝至 /etc/confd
2. 修改 cluster.json.mustache 的 KVM 镜像号码，上传至 APPCenter

## 2 帮助点

### 2.1 开发文档

- config.json, config.json.mustache: https://docs.qingcloud.com/appcenter/docs/specifications/specifications.html#clusterjsonmustache

### 2.2 如何制作主机镜像

在主机资源列表页，选择主机，右单机出现菜单后，单击“制作主机新映像”

### 2.3 拷贝 confd 文件
```
cp -r /opt/kubernetes/confd/conf.d /etc/confd/
cp -r /opt/kubernetes/confd/templates /etc/confd/
```

## 3 KubeSphere APP 制作过程

### 3.1 下载代码

执行 `image/pre-build.md` 的代码内容，进入 /opt/kubernetes
```
git clone https://github.com/wnxn/kubesphere-1.git /opt/kubernetes
cd /opt/kubernetes
```

### 3.2 下载 KVM 镜像依赖

```
cd /image
./build-base.sh
```

### 3.3 制作 KVM 镜像

在 QingCloud Console 关闭主机，制作映像。

### 3.4 修改 cluster.json.mustache

将映像 id 填到 mustache 的 image 里

### 3.5 打包 config 

```
tar -cf config.tar /app/ha/config
```

并且上传至 Appcenter 新版本 app 内

## 4 调试
## 4.1 获得 Metadata 数据

```
curl http://metadata/self
curl http://192.168.253.5/self
```

## 4.2 重新载入 confd 配置文件

```
/opt/qingcloud/app-agent/bin/confd -onetime
```

## 4.3 启用 Kubectl

- For root user

```
export KUBECONFIG=/etc/kubernetes/admin.conf
```

- For all user

```
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```