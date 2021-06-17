# Scripts

> 该文档记录一些常用的工具指令，便于复制

- v2ray v2-ui 一键部署

```sh
curl -Ls https://blog.sprov.xyz/v2-ui.sh | bash -
```

- ohmyzsh

```sh
# from github
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

- docker 批量删除镜像，加过滤条件

```sh
# docker
docker rmi `docker images | grep dk.uino.cn/thingyouwe/ | awk '{print $3}'`
# k3s crictl
k3s crictl rmi `k3s crictl images | grep dk.uino.cn/thingyouwe | awk '{print $3}'`
```

- docker 运行 mongodb

```sh
docker run -d --name mongodb -p 27017:27017  \
  -e MONGO_INITDB_ROOT_USERNAME=sasukebo \
  -e MONGO_INITDB_ROOT_PASSWORD=123456 \
  mongo
```

- docker 运行 postgresql

```sh
docker run -d \
--name postgres \
-p 5432:5432 \
-e POSTGRES_PASSWORD=123456 \
-e PGDATA=/var/lib/postgresql/data/pgdata \
-v $PWD/mount:/var/lib/postgresql/data \
postgres
```

- docker 运行 nats

```sh
docker run -d \
  --name nats-main \
  --network thingyouwe-local \
  -p 4222:4222 \
  -p 6222:6222 \
  -p 8222:8222 \
  nats
```

- docker 运行 etcd-server

```sh
docker run -d --name etcd-server \
    --network thingyouwe-local \
    --publish 2379:2379 \
    --publish 2380:2380 \
    --env ALLOW_NONE_AUTHENTICATION=yes \
    --env ETCD_ADVERTISE_CLIENT_URLS=http://etcd-server:2379 \
    bitnami/etcd:latest
```

- docker 运行 redis

```sh
docker run -d \
  --name redis \
  --network thingyouwe-local \
  -p 6379:6379 \
  redis
```
