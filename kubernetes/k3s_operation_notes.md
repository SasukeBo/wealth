# K3s 运维笔记

## 如何扩大 k3s Agent 最大可运行 pods 数量

修改 `/etc/systemd/system/k3s-agent.service` 文件，将 `ExecStart`项添加参数：

```service
ExecStart=/usr/local/bin/k3s agent '--kubelet-arg=max-pods=200'
```

保存后重启节点即可：

```sh
systemctl daemon-reload
systemctl restart k3s-agent
```

## 释放节点

- 驱散
- 卸载 k3s-agent/k3s
- 在 master 节点 kubectl delete nodes YOUR_NODE_NAME
- 直接使用 kubectl delete nodes 删除 master 节点，在多 master 节点的集群上是不会产生影响的

## 如何释放 linux 主机中缓存的内存

```sh
echo 1 > /proc/sys/vm/drop_caches
```
