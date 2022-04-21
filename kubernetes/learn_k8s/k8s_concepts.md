# 概念

> 概念部分可以帮助你了解 Kubernetes 的各个组成部分以及 Kubernetes 用来表示集群的一些抽象概念，并帮助你更加深入的理解 Kubernetes 是如何工作的。

## 概述

早期的应用部署是直接在物理机上部署，物理机直接部署往往会导致资源分配问题。例如，多个应用同时运行在一台物理机上，其中一个应用占用大量资源时，其他应用也会受到影响。
未解决物理机直接部署带来的问题，开始引入虚拟化技术，一台物理机上可以同时运行多个虚拟机，将应用部署在虚拟机上，虚拟机之间资源隔离。但是这种解决方案会造成很多资源的浪费在运行虚拟机本身。
很快容器部署时代到来，容器类似于 VM，但是它们具有被放宽的隔离属性，可以在应用程序之间共享操作系统。
因此容器被视为是轻量级的。

### 为什么需要 K8S

容器是打包和运行应用程序的好方式。在生产环境中，你需要管理运行应用程序的容器，并确保不会停机。 例如，如果一个容器发生故障，则需要启动另一个容器。如果系统处理此行为，会不会更容易？

提供：

- 服务发现和负载均衡

  > Kubernetes 可以使用 DNS 名称或自己的 IP 地址公开容器，如果进入容器的流量很大， Kubernetes 可以负载均衡并分配网络流量，从而使部署稳定。

- 存储编排
- 自动部署和回滚
- 自动完成装箱计算
- 自我修复
  > Kubernetes 重新启动失败的容器、替换容器、杀死不响应用户定义的 运行状况检查的容器，并且在准备好服务之前不将其通告给客户端。
- 密钥与配置管理

## [Kubernetes 组件](https://kubernetes.io/zh/docs/concepts/overview/components)

集群由一组被称作节点的机器组成，这些节点上运行 Kubernetes 所管理的容器化应用。集群具有至少一个工作节点。

### 控制平面组件

控制平面的组件对集群做出全局决策(比如调度)，以及检测和响应集群事件。

#### kube-apiserver

API 服务器是 Kubernetes 控制面的组件， 该组件公开了 Kubernetes API。

#### etcd

etcd 是兼具一致性和高可用性的键值数据库，可以作为保存 Kubernetes 所有集群数据的后台数据库。

#### kube-scheduler

主节点上的组件，该组件监视那些新创建的未指定运行节点的 Pod，并选择节点让 Pod 在上面运行

#### kube-controller-manager

在主节点上运行 控制器 的组件，这些控制器包括:

- 节点控制器（Node Controller）: 负责在节点出现故障时进行通知和响应。
- 副本控制器（Replication Controller）: 负责为系统中的每个副本控制器对象维护正确数量的 Pod。
- 端点控制器（Endpoints Controller）: 填充端点(Endpoints)对象(即加入 Service 与 Pod)。
- 服务帐户和令牌控制器（Service Account & Token Controllers）: 为新的命名空间创建默认帐户和 API 访问令牌。

#### cloud-controller-manager

云控制器管理器是指嵌入特定云的控制逻辑的 控制平面组件。 云控制器管理器允许您链接聚合到云提供商的应用编程接口中， 并分离出相互作用的组件与您的集群交互的组件。

### Node 组件

节点组件在每个节点上运行，维护运行的 Pod 并提供 Kubernetes 运行环境。

#### kubelet

一个在集群中每个节点上运行的代理。 它保证容器都运行在 Pod 中。

#### kube-proxy

是集群中每个节点上运行的网络代理， 实现 Kubernetes 服务（Service） 概念的一部分

#### 容器运行时

容器运行环境是负责运行容器的软件。例如：Docker

## [理解 Kubernetes 对象](https://kubernetes.io/zh/docs/concepts/overview/working-with-objects/kubernetes-objects/)

在 Kubernetes 系统中，Kubernetes 对象 是持久化的实体。 Kubernetes 使用这些实体去表示整个集群的状态。

### 对象规约（Spec）与状态（Status）

几乎每个 Kubernetes 对象包含两个嵌套的对象字段，它们负责管理对象的配置： 对象 spec（规约） 和 对象 status（状态） 。

- 对于具有 spec 的对象，你必须在创建对象时设置其内容，描述你希望对象所具有的特征： 期望状态（Desired State） 。
- status 描述了对象的 当前状态（Current State），它是由 Kubernetes 系统和组件 设置并更新的。在任何时刻，Kubernetes 控制平面 都一直积极地管理着对象的实际状态，以使之与期望状态相匹配。

### 描述 Kubernetes 对象

创建 Kubernetes 对象时，必须提供对象的规约，用来描述该对象的期望状态， 以及关于对象的一些基本信息（例如名称）。

例如下面的 deployment.yaml

```yaml
apiVersion: apps/v1 # for versions before 1.9.0 use apps/v1beta2
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  selector:
    matchLabels:
      app: nginx
  replicas: 2 # tells deployment to run 2 pods matching the template
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
        - name: nginx
          image: nginx:1.14.2
          ports:
            - containerPort: 80
```

## [命名空间](https://kubernetes.io/zh/docs/concepts/overview/working-with-objects/namespaces/)

Kubernetes 支持多个虚拟集群，它们底层依赖于同一个物理集群。 这些虚拟集群被称为名字空间。

## Kubernetes 的基本概念和术语

几乎所有资源对象都可以通过 Kubectl 工具或者 API 进行 CURD 并持久化在 etcd 中。跟踪对比 etcd 中记录的期望值与实际资源状态的差异，实现自动控制和自动纠错的高级功能。

我们可以用 yaml 或者 json 定义一个资源对象，每种对象有自己的特定语法格式，可以理解为数据库中一个特定的表。

Annotations 是为了实现新版本迭代增加的新属性，由于增加新属性需要有对应的数据库表字段存储，如果直接修改表结构添加字段，改动范围比较大，风险更大，会造成旧版本配置失效等问题。
所以，采用备注的方式来存储新特性（属性），待新特性稳定成熟之后可以修改表结构，发布到正式版本，这就是通用字段 Annotations 的作用。

---

_最后编辑于 2020 年 12 月 15 日 16:33:20_

[返回目录](./menu.md)
