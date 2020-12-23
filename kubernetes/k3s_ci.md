# K3S 搭建流水线

## 使用 k3s 部署代码仓库 gitlab

在 rancher 中部署 gitlab 十分的便捷。

- 在你的项目中点击部署服务，在`Docker镜像`中填入官方社区版镜像`gitlab/gitlab-ce`。
- 配置端口映射，需要将 gitlab 容器内的 80 和 22 端口映射出来。
- 需要配置数据卷的挂载
  在数据卷 -> 添加卷 -> 映射主机目录
  由于 gitlab 一般都是单 pod 部署，推荐将服务部署到指定的节点。
  需要挂载的容器路径有：

  - /var/log/gitlab 日志输出地址
  - /var/opt/gitlab 数据存储地址
  - /etc/gitlab gitlab 配置信息存储地址

- 修改 gitlab.rb 来调整配置

在文件末尾添加配置

```ruby
external_url 'http://yourgitlab_ip:port'
nginx['listen_port'] = 80
nginx['listen_https'] = false
gitlab_rails['gitlab_shell_ssh_port'] = 32222
```

**注意** gitlab_shell_ssh_port 仅仅改变了 ssh 克隆代码的前端界面显示，实际上 gitlab 的 ssh 还是监听 22 端口，所以通过 rancher 做 22 端口映射至其他端口并不能生效，ssh 会直接拒绝或无法验证部署在 gitlab 上的 ssh 公钥。

## 配置镜像仓库凭证

镜像库凭证其实也是一个 Kubernetes Secret。这个 Secret 包含用于向私有 Docker 镜像库进行身份验证的凭据。

> 先决条件：有一个可被使用的私有镜像库

1. 从 全局 视图， 选择您想要添加一个镜像库凭证的命名空间所在的项目。
2. 通过主目录， 单击 资源 > 密文 > 镜像库凭证。
3. 单击添加凭证。
4. 为镜像库凭证设置名称。
5. 为这个镜像库凭证选择一个范围。您可以设置此镜像库凭证作用于此项目所有命名空间或单个命名空间。
6. 选择您的私有镜像库的类型，然后输入私有镜像库的凭证。例如，如果您使用 DockerHub，请提供您的 DockerHub 用户名和密码。
7. 单击保存。

[官方文档](https://docs.rancher.cn/docs/rancher2/k8s-in-rancher/registries/_index)

## 设置代码仓库

1. 从全局视图，导航到您想要配置流水线的项目。
2. 点击资源 > 流水线
3. 点击设置代码库
4. 显示代码库列表。如果您是第一次配置代码库，点击 认证 & 同步代码库去刷新您的代码库列表。
5. 对于您想设置流水线的每个代码库，点击启用。
6. 当您启用所有代码库后，点击完成。

启用流水线代码库的配置文件可以参照[pipeline-example-go](https://github.com/rancher/pipeline-example-go)

[官方文档](https://docs.rancher.cn/docs/rancher2/k8s-in-rancher/pipelines/_index)

---

_最后编辑于 2020 年 12 月 22 日 17:39:05_

[返回目录](./menu.md)
