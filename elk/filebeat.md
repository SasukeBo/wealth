# Filebeat

> 该文档主要记录 Filebeat 学习笔记

## 安装

### 使用 docker 安装

下载一个配置文件样板：[filebeat.docker.yml](https://raw.githubusercontent.com/elastic/beats/7.11/deploy/docker/filebeat.docker.yml)

```sh
curl -L -O https://raw.githubusercontent.com/elastic/beats/7.11/deploy/docker/filebeat.docker.yml
```

启动容器

```sh
docker run -d \
  --name=filebeat \
  --user=root \
  --network=elk-network \
  --volume="$(pwd)/filebeat.docker.yml:/usr/share/filebeat/filebeat.yml:ro" \
  --volume="/var/lib/docker/containers:/var/lib/docker/containers:ro" \
  --volume="/var/run/docker.sock:/var/run/docker.sock:ro" \
  docker.elastic.co/beats/filebeat:7.11.1 filebeat -e -strict.perms=false
```

## 二级标题

正文

---

_最后编辑于 2020 年 12 月 15 日 16:34:41_

[返回目录](./menu.md)
