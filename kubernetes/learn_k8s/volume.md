# Volumn

## Volume 类型

k8s 提供了非常丰富的 Volume 类型，常用的有`emptyDir`, `hostPath`, `NFS`

- emptyDir

当 Pod 被分配到 Node 上是创建的，初始内容为空，且无需指定宿主机上对应的文件目录，相当于是 Pod 的临时空间，用于给 Pod 中的容器共享数据资源的目录。Pod 被删除后，emptyDir 也会随之被删除。

- hostPath

hostPath 为在 Pod 上挂载宿主机上的文件目录，它通常可以用于为容器永久保存日志文件，或者容器需要访问宿主机上的 docker 引擎内部数据结构时。

- NFS

使用 NFS 网络文件系统提供的共享目录存储数据，需要预先在系统中部署一个 NFS Server。

## Persistent Volume

PV 可以被理解为 Kubernetes 集群中的某个网络存储对应的一块存储，它与 Volume 类似。

- PV 只能是网络存储，不属于任何 Node，但可以在每个 Node 上访问。
- PV 并不是被定义在 Pod 上的，而是独立于 Pod 之外定义的。
