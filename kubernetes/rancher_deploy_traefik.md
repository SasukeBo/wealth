# 使用 Rancher 搭建 traefik

## 配置 traefik 的映射文件

主要需要配置 traefik 的基础配置`traefik.toml`和动态路由配置文件`dynamic_conf.toml`

- 在`项目`中选中一个`命名空间`，在`资源`菜单栏中选择`配置映射`，然后点击`添加配置映射`。
- 填写一个映射名称，例如`api-gateway-config`。
- 选择一个命名空间。
- 添加 traefik 配置映射值

  - key = `traefik.toml`
  - value 为 类似如下内容：

```toml
[global]
  checkNewVersion = true
  sendAnonymousUsage = true

[entryPoints]
  [entryPoints.web]
    address = ":80"
  [entryPoints.websecure]
    address = ":443"

[log]
  level = "DEBUG"

[api]
  dashboard = true

[ping]

[providers]
  [providers.file]
    filename = "/etc/traefik/dynamic_conf.toml"
    watch = true

[tracing]
  serviceName = "api-gateway"
```

traefik 配置可以参考[官方文档](https://doc.traefik.io/traefik/providers/rancher/)。

- 添加动态路由映射值

  - key = `dynamic_conf.toml`
  - value 为类似如下内容：

```toml
# http routing section
[http]

[http.routers]

[http.routers.ws-api]
rule = "PathPrefix(`/websocket`)"
service = "ws-api"

[http.services]

[http.services.ws-api.loadBalancer]
passHostHeader = true

[[http.services.ws-api.loadBalancer.servers]]
url = "http://ws-srv"
```

traefik 动态路由的配置规则也可以查阅[官方文档](https://doc.traefik.io/traefik/providers/rancher/)。

## 部署工作负载

- 在`项目`中选中一个`命名空间`，在`资源`菜单栏中选择`工作负载`，然后点击`部署服务`。
- 填写镜像名称为`traefik`，选择`命名空间`。
- 添加端口`80`映射 ，选择集群内访问。
- 在`主机调度`中指定主机运行所有 pods。
- 在`数据卷`中配置映射卷，用来配置之前添加的 traefik 路由配置，容器路径填写`/etc/traefik/`。
- 点击启动。

## 通过服务发现开放 ip 端口访问网关

traefik 启动成功后会自动创建服务发现，如果没有域名，可以通过配置服务发现来开放公网端口访问。

- 在菜单栏中：资源 -> 工作负载 -> 服务发现，点击进入 traefik 服务的服务发现详情。
- 点击`升级`该记录。
- 点击`显示高级选项`。
- 类型选择为`NodePort`。
- 填写外网 IP，配置端口映射，将集群内 80 端口映射到主机的端口，注意，该端口需要在服务器防火墙配置中打开。

## 通过域名配置服务发现访问网关

> 前提是要有一个域名，并将该域名解析到你的服务器 80 端口上。

- 在菜单栏中：资源 -> 工作负载 -> 负载均衡。
- 点击添加规则。
- 填写名称。
- 选择命名空间。
- 选择自定义域名，填入你的域名。
- 后端目标中选择工作负载指向网关服务，填写容器的端口，这里配置的是 80 端口。
- 保存

完成设置之后进入工作负载查看网关服务，你会发现多了一个 80 端口的访问通道。

---

_最后编辑于 2020 年 12 月 24 日 15:44:41_

[返回目录](./menu.md)
