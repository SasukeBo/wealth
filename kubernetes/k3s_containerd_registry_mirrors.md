# K3s 集群节点设置 containerd 镜像加速

- 创建配置文件模板

```shell
cp /var/lib/rancher/k3s/agent/etc/containerd/config.toml /var/lib/rancher/k3s/agent/etc/containerd/config.toml.tmpl
```

**注意** 修改 containerd 配置文件必须通过模板，直接修改 config.toml 会在 k3s 服务重启的时候覆盖为原有配置。

- 修改配置文件，添加镜像仓库配置

在`config.toml.tmpl`文件中添加以下配置

```toml
[plugins.cri.registry.mirrors]
  [plugins.cri.registry.mirrors."docker.io"]
    endpoint = ["<镜像仓库地址>"]
    # 可以去网上随便找一个阿里云的镜像仓库，例如：https://vcw3fe1o.mirror.aliyuncs.com
```

- 重启 k3s 使配置生效

```shell script
# 如果是master节点主机，重启k3s服务
systemctl restart k3s

# 如果是worker节点主机，重启k3s-agent服务
systemctl restart k3s-agent
```

- 检查配置是否生效

```shell script
crictl info | grep -A 5 registry
```

返回结果：

```json
"registry": {
  "mirrors": {
    "docker.io": {
      "endpoint": [
        "<镜像仓库地址>"
      ]
    }
  }
}
```
