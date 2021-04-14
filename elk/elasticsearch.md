# Elasticsearch

> 本文档主要记录 Elasticsearch 的学习笔记

## 安装 Elasticsearch

### 使用 docker 安装 Elasticsearch

```sh
docker run -d --name elasticsearch \
  --net elk-network \
  -p 9200:9200 -p 9300:9300 \
  -e "discovery.type=single-node" \
  elasticsearch:latest
```

以单节点的模式运行 Elasticsearch 容器

---

_最后编辑于 2021 年 03 月 04 日 19:15:33_

[返回目录](./menu.md)
