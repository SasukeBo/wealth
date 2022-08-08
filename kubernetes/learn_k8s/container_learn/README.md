# 容器技术概念入门

## Linux namespace

举例来说，pid namespace 技术是专门针对进程 id 进行隔离的功能。
通过 pid namespace 可以将容器中的进程进行隔离，在容器内，进程 id 是重新计算的，比如

```sh
docker run --rm --it busybox /bin/sh
```

启动 docker 容器并在内部运行一个/bin/sh 进程，这对于容器而言是第一个进程，对于宿主机则不是。

除了`pid namespace`，linux 内核还支持`Mount/UTS/IPC/Network/User`这些 namespace，可被容器技术用于隔离这些资源信息。

docker 实际上就是在创建容器进程时，指定了这个进程所需启动的一组 Namespace 参数。

## 隔离与限制

虚拟化会带来额外的开销，而容器技术的进程实际还是运行在宿主机上。

但，单凭 Namespace 的隔离是不够彻底的。
而且，有很多资源和对象是不能被 Namespace 化的，比如时间。

`Linux Cgroups`就是 linux 内核中用来为进程设置资源限制的重要功能，它最主要的功能就是限制一个进程组能够使用的资源上限，包括 CPU、内存、磁盘和网络带宽等。

`docker run`启动一个容器的时候会在`/sys/fs/cgroup`的某一目录下为该容器创建一个目录，并通过配置文件来告诉 cgroup 如何限制这个容器进程组的资源。

```sh
$ docker ps
#=> CONTAINER ID
#=> f1b0c552aaf6

# Ubuntu 22.04 LTS
$ ls /sys/fs/cgroup/system.slice | grep f1b0c552aaf6
#=> docker-f1b0c552aaf6.scope
```

![cgroup_daemon](1.png)

总结

- 由于容器的本质就是一个进程，这就意味着在一个容器里没有办法同时运行两个不同的应用。
- 容器本身的设计是希望容器与应用同生命周期。
- /proc 文件系统不知晓 cgroup 对进程组的资源限制，所以在容器内执行 top、free 得出的结果实际就是宿主机的 cpu、内存结果。
  - 如何解决这个问题？在宿主机安装 lxcfs 服务，该服务会根据 cgroup 限制为进程读取其对应的资源量，通过将容器的`/proc/meminfo`挂载到`/var/lib/lxcfs/proc/meminfo`就可以读取容器进程的资源用量。

## 容器镜像

仅仅靠`Mount Namespace`是做不到文件系统的隔离，在容器内还是能够直接访问到宿主机的文件系统。
Mount Namespace 修改的是容器进程对文件系统的“挂载点”的认知。所以除了声明启用`Mount Namespace`还需要告诉容器进程，有哪些目录需要重新挂载。

chroot 命令可以轻松为容器进程更改根目录，Mount Namespace 正是基于对 chroot 不断改良而产生的。
为了让容器进程根目录看起更真实，一般会在这个容器的根目录下挂载完整的操作系统的文件系统，比如 ubuntu 的 ISO。
而这个挂载在容器根目录上、用来为容器进程提供隔离后执行环境的文件系统，就是所谓的“容器镜像”。它还有一个更为专业的名字，叫作：rootfs（根文件系统）

rootfs 只包含了操作系统的躯壳，而其灵魂“内核”则是与宿主机共享内核，所以对于所有容器而言，宿主机内核参数是全局变量，牵一发而动全身。

docker 打包了 rootfs，从而保证了一致性，local 和 PaaS 只需要保证内核一致，就可以做到一致性。

现如今 docker 一般使用 overlayfs 来实现增量 rootfs 联合挂载的能力。

- Overlayfs 是一种类似 aufs 的一种堆叠文件系统

## 重新认识 Docker 容器

Linux Namespace 虽然是一个看不见摸不着的概念，但是容器进程运行时的 Namespace 配置在宿主机上却可以找得到。

```sh
docker run --rm --name helloworld helloworld
docker inspect --format '{{ .State.Pid }}' helloworld
#=> pid=25686

sudo ls -l /proc/25686/ns
#=>
# lrwxrwxrwx 1 root root 0 Aug  5 09:33 net -> 'net:[4026533082]'
# ...
```

能够看到指定容器的网络命名空间。linux 操作系统上一切皆是文件，知道这个文件就可以加入到这个 Namespace 中。
这也是`docker exec`实现前提。


