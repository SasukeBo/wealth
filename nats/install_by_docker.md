# 使用 docker 部署 NATS 集群

## NATS 端口说明

- `4222` 使用与连接客户端的
- `8222` 是一个 HTTP 端口，用于管理
- `6222` 是用于集群连接的端口

## 默认的配置文件

nats-server.conf

```conf
# Client port of 4222 on all interfaces
port: 4222

# HTTP monitoring port
monitor_port: 8222

# This is for clustering multiple servers together.
cluster {
  # It is recommended to set a cluster name
  name: "my_cluster"

  # Route connections to be received on any interface on port 6222
  port: 6222

  # Routes are protected, so need to use them with --routes flag
  # e.g. --routes=nats-route://ruser:T0pS3cr3t@otherdockerhost:6222
  authorization {
    user: ruser
    password: T0pS3cr3t
    timeout: 0.75
  }

  # Routes are actively solicited and connected to from this server.
  # This Docker image has none by default, but you can pass a
  # flag to the nats-server docker image to create one to an existing server.
  routes = []
}
```

### 启动第一个节点

```sh
docker run -d --name nats-main \
  --network sasukebo \
  -v $PWD/nats-server.conf:/nats-server.conf \
  -p 4222:4222 \
  -p 8222:8222 \
  -p 6222:6222 \
  nats -c /nats-server.conf
```

### 启动第二个节点

```sh
docker run -d \
  --name nats-node-2 \
  --network sasukebo \
  -v $PWD/nats-server.conf:/nats-server.conf \
  -p 4223:4222 -p 6223:6222 -p 8223:8222 \
  nats -c /nats-server.conf \
  --routes=nats-route://sasukebo:123456@nats-main:6222 -DV
```

-DV 用于 Debug 输出日志

成功加入集群则会看到日志：

```sh

[1] 2021/04/21 08:29:45.631966 [DBG] Trying to connect to route on nats-main:6222 (172.21.0.2:6222)
[1] 2021/04/21 08:29:45.632239 [DBG] 172.21.0.2:6222 - rid:3 - Route connect msg sent
[1] 2021/04/21 08:29:45.632273 [INF] 172.21.0.2:6222 - rid:3 - Route connection created
```
