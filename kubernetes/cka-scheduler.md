# Day 1
## Chapter 1：课程介绍
1. ~~理解 Kubernetes 设计原则、原理~~
1. ~~了解 Kubernetes 的过去、现在和未来~~
1. 了解并学会使用 Kubernetes 最重要的资源 — API
1. 学会如何创建和管理应用，并配置应用外部访问
1. 理解 Kubernetes 网络、存储
1. 掌握 Kubernetes 调度的原理和策略
1. Kubernetes 一些新功能的概念
1. 了解 Kubernetes 的日志、监控方案
1. 具备基本的故障排查的运维能力

## Chapter 2：Kubernetes 基本概念

1. 了解什么是 Kubernetes
1. 了解 Kubernetes 的主要特性
1. 理解为什么需要 Kubernetes
1. 了解 Kubernetes 的过去、现在和未来
1. 了解目前 Kubernetes 社区的情况和被采用情况
1. 了解 Kubernetes 的基本架构
1. 获得一些学习资料推荐

## Chapter 3：Kubernetes 架构及原理

1. 理解 Kubernetes 设计原则
1. 深入理解 Kubernetes 集群中的组件及功能
1. 了解 Kubernetes 集群对网络的预置要求
1. 深入理解 Kubernetes 的工作原理
1. 深入理解 Kubernetes 中 Pod 的设计思想

## Chapter 4：Kubernetes 安装和配置

1. 了解部署 Kubernetes 的多种方式
1. 可以单机部署 Kubernetes（学习演示使用）
1. 可以在宿主机部署一套 Kubernetes 集群（非生产使用）

## Chapter 5：Kubernetes API 及集群访问

1. 了解 Kubernetes 的 API
1. 理解 Kubernetes 中 API 资源的结构定义
1. 了解 kubectl 工具的使用
1. 了解 Kubernetes 中 API 之外的其他资源

## Chapter 6：ReplicaController，ReplicaSets 和 Deployments

1. 理解 RC
1. 理解 label 和 selector 的作用
1. 理解 RS
1. 理解 Deployments 并且可操作 Deployments
1. 理解 rolling update 和 rollback

## Chapter 7：Volume、配置文件及密钥

1. 了解 Kubernetes 存储的管理，支持存储类型
1. 理解 Pod 使用 volume 的多种工作流程以及演化
1. 理解 pv 和 pvc 的原理
1. 理解 storage class 的原理
1. 理解 configmaps 的作用和使用方法
1. 理解 secrets 的作用和使用方法资源结构

# Day 2
## Chapter 8：Service 及服务发现

1. 了解 Docker 网络和 Kubernetes 网络
1. 了解 Flannel 和 Calico 网络方案
1. 理解 Pod 在 Kubernetes 网络中的工作原理
1. 理解 Kubernetes 中的 Service
1. 理解 Service 在 Kubernetes 网络中的工作原理
1. 理解 Kubernetes 中的服务发现
1. 掌握 Kubernetes 中外部访问的几种方式

## Chapter 9：Ingress 及负载均衡

1. 理解 Ingress 和 Ingress controller 的工作原理
1. 掌握如何创建 Ingress 规则
1. 掌握如何部署 Ingress controller

# Day 3
## Chapter 10：DaemonSets，StatefulSets，Jobs，HPA，RBAC

1. 了解 DaemonSet 资源和功能
1. 了解 StatefulSet 资源和功能
1. 了解 Jobs 资源和功能
1. 了解 HPA 资源和功能
1. 了解 RBAC 资源和功能

## Chapter 11：Kubernetes 调度

1. 理解 Pod 调度的相关概念
1. 深度理解 Kubernetes 调度策略和算法
1. 深度理解调度时的 Node 亲和性
1. 深度理解调度时的 Pod 亲和性和反亲和性
1. 深度理解污点和容忍对调度的影响
1. 深度理解强制调度 Pod 的方法

## Chapter 12：日志、监控、Troubleshooting

1. 理解 Kubernetes 集群的日志方案
1. 理解 Kubernetes 集群的监控方案
1. 了解相关开源项目：Heapster，Fluentd，Prometheus 等
1. 掌握常用的集群，Pod，Service 等故障排查和运维手段

## Chapter 13：自定义资源 CRD

1. 理解和掌握 Kubernetes 中如何自定义 API 资源
1. 可以通过 kubectl 管理 API 资源
1. 了解用于自定义资源的 Controller 及相关使用示例
1. 了解 TPR 和 CRD

## Chapter 14：Kubernetes Federation

1. 了解 Kubernetes 中 Federation 的作用和原理
1. 了解 Federation 的创建过程
1. 了解 Federation 支持的 API 资源
1. 了解集群间平衡 Pod 副本的方法

## Chapter 15：应用编排 Helm，Chart

1. 了解 Kubernetes 中如何进行应用编排
1. 了解 Helm 的作用和工作原理
1. 了解 Tiller 的作用和工作原理
1. 了解 Charts 的作用和工作原理

## Chapter 16：Kubernetes 安全

1. 了解 Kubernetes 中 API 访问过程
1. 了解 Kubernetes 中的 Authentication
1. 了解 Kubernetes 中的 Authorization
1. 了解 ABAC 和 RBAC 两种授权方式
1. 了解 Kubernetes 中的 Admission
1. 了解 Pod 和容器的操作权限安全策略
1. 了解 Network Policy 的作用和资源配置方法
