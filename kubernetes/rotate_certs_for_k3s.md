# K3s 证书轮换

[官方文档](https://rancher.com/docs/k3s/latest/en/advanced/#certificate-rotation)指出：

> By default, certificates in K3s expire in 12 months.
> If the certificates are expired or have fewer than 90 days remaining before they expire, the certificates are rotated when K3s is restarted.

也就是说 k3s 在距离证书过期 90 天内，重启服务会自动进行证书的轮换，当前森友会生产环境的 k3s 版本是`v1.21.2+k3s1`，需要验证集群版本是否支持这种功能。
另外还需要验证证书轮换后的 rancher 还能否正常管理集群。

## Copy 一套环境

- aliyun 用量计费创建一台云 ESC
- 搭建 k3s-server 单节点 k8s 集群
- 启动 rancher 容器单节点管理集群
- 调整服务器时间至证书过期时间 90 天内
- 重启 k3s-server 并检查证书是否轮换
- 如果能够轮换，检查原版 rancher 是否能够继续管理集群

### 版本

- k3s `v1.21.2+k3s1`
- rancher `v2.5.8`

```sh
sudo docker run -d --restart=unless-stopped --privileged --name rancher -p 30080:80 -p 30443:443 rancher/rancher:v2.5.8
```

### 场景模拟

- 检查现有的证书有效期

k3s 证书存放路径在`/var/lib/rancher/k3s/server/tls/`下，通过 openssl 工具可以解析证书的内容。

```sh
for i in `ls /var/lib/rancher/k3s/server/tls/*.crt`; do echo $i; openssl x509 -dates -noout -in $i; done
```

- 修改服务器时间

先关闭自动同步时间

```sh
timedatectl set-ntp false
```

设置一个距今 90 天内的时间

```sh
timedatectl set-time '2019-01-01 00:00:00'
```

重启 k3s 服务

```sh
systemctl restart k3s
```

再次检查证书有效期发现已经被续期了一年。

### 问题

- k3s 一直在报`Unable to authenticate the request err=[invalid bearer token, Token has expired.]`

- rancher 重新 import 集群时报错`Failed while: Wait for Condition: InitialRolesPopulated: True`

  - 相关[issue](https://github.com/rancher/rancher/issues/25744)
  - 查看 rancher local 集群 system 项目下的所有命名空间服务都处于 updating 状态，看问题应该是 cattle-system rancher-webhook 工作证书过期造成的问题
  - [官网资料](https://rancher.com/docs/rancher/v2.6/en/troubleshooting/expired-webhook-certificates/)
  - 进入 rancher 容器，删除官网指出的证书配置，尝试重启 rancher，是否能够自动生成最新的配置。

```sh
kubectl delete secret -n cattle-system cattle-webhook-tls
kubectl delete mutatingwebhookconfigurations.admissionregistration.k8s.io --ignore-not-found=true rancher.cattle.io
kubectl delete pod -n cattle-system -l app=rancher-webhook
```

重启 rancher 后，本地集群也会跟着重启，cattle-webhook-tls 也恢复正常

- 重新导入需要移除掉目标集群 cattle-system 命名空间及其所属的所有资源，直接 delete namespace 会因为资源未清理保持 Terminating

需要手动修改 namespace 的 yaml 文件

```sh
NS=`kubectl get ns |grep Terminating | awk 'NR==1 {print $1}'` && kubectl get namespace "$NS" -o json   | tr -d "\n" | sed "s/\"finalizers\": \[[^]]\+\]/\"finalizers\": []/"   | kubectl replace --raw /api/v1/namespaces/$NS/finalize -f -
```

- 导入集群后，cattle-cluster-agent 从 rancher 获取的证书为过期的

根据[文档](https://docs.rancher.cn/docs/rancher2/cluster-admin/certificate-rotation/_index/#%E7%8B%AC%E7%AB%8B%E5%AE%B9%E5%99%A8-rancher-server-%E8%AF%81%E4%B9%A6%E6%9B%B4%E6%96%B0)操作，移除掉过期的配置:

```sh
kubectl --insecure-skip-tls-verify -n kube-system delete secrets k3s-serving
kubectl --insecure-skip-tls-verify delete secret serving-cert -n cattle-system
rm -f /var/lib/rancher/k3s/server/tls/dynamic-cert.json
```

重启 rancher 会轮换为最新的证书。

### 重新验证一遍

能否在不重新导入集群的情况下轮换 rancher 和 k8s 集群证书。

- 将服务器时间继续向后推迟

例如，当前 k8s 证书过期时间为 2025 年 6 月 31 日，将服务器时间设置为 2025 年 6 月 1 日，重启 k3s 之后证书更新到了 2026 年。
但是 rancher 中的 local 集群证书目前没有更新，应该还是 2025 年 6 月 31 日附近过期。
此时将服务器时间继续向后推迟到 2025 年 8 月 1 日，rancher 应该会对导入的 k8s 集群失去控制权。

- 轮换 rancher 容器 local 集群证书

  重启 rancher，此时 rancher 容器会一直报错，主要是容器内集群组件之间的 ca 文件失效造成，进入容器后将上面所列举的过期配置全部移除，并将负责管理集群的 local 集群中的负载`cattle-webhook-tls`相关资源清除，重启 rancher 后，rancher 会根据最新时间轮换 local 集群证书，并重新启动`cattle-webhook-tls`资源。

- 被管理 k8s 集群重新获取 rancher local 集群 ca 证书

只需要删除现有的负责代理集群的负载 cattle-cluster-agent 生成的 pods，重新启动会向 rancher 证书地址获取最新的 ca 证书

```sh
kubectl delete -n cattle-system pod -l app=cattle-cluster-agent
```

## 总结

先重启 k3s server，完成证书轮换。
轮换 rancher local 集群证书。
期间业务集群中的服务不会中断。
