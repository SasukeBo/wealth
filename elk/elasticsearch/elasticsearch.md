# Elasticsearch

> 本文档主要记录 Elasticsearch 的学习笔记

## 安装 Elasticsearch

使用 docker 安装 Elasticsearch 和 Kibana 来学习 Elasticsearch 的查询语法。

- 安装 Elasticsearch

```sh
docker run \
  --rm --name es01-test \
  --net elastic \
  -p 9200:9200 -p 9300:9300 \
  -e "discovery.type=single-node" \
  docker.elastic.co/elasticsearch/elasticsearch:7.12.1
```

以单节点的模式运行 Elasticsearch 容器，如果要重复使用容器内的

- 安装 Kibana

```sh
docker run \
  --rm --name kib01-test \
  --net elastic \
  -p 80:5601 \
  -e "ELASTICSEARCH_HOSTS=http://es01-test:9200" \
  docker.elastic.co/kibana/kibana:7.12.1
```

## 搜索 —— 最基本的工具

- 映射 Mapping
  描述数据在每个字段内如何存储

- 分析 Analysis
  全问是如何处理使之可以被搜索的

- 领域特定查询语句 Query DSL
  Elasticsearch 中强大灵活的查询语句

## Search Your Data

### Post Filter

`post_filter` 参数被用来过滤搜索结果：

```json
"post_filter": {
  "term": {"color": "red"}
}
```

对过滤结果的 `color` 属性进行筛选，过滤掉颜色不是红色的 shirt

### Rescore filterd search results

`Query Rescorer` 对 `query` 和 `post_filter`短语查询的数据结果的 TOP-K 条数据进行二次查询。

```json
  "rescore": {
    // 对 top 50 的记录进行二次查询
    "window_size": 50,
    "query": {
      "rescore_query": {
        "match_phrase": {
          "name": {
            "query": "土壤",
            "slop": 2
          }
        }
      },
      "query_weight": 0.7,
      "rescore_query_weight": 1.2
    }
  }
```

对前面的查询结果做二次查询，二次查询中又对`name`做了值为`土壤`的查询，并配置了权重。

### Highlighting

可以将搜索结果命中的地方返回高亮的代码块

```json
"highlight": {
  "fields": {
    "name": {}
  }
}
```

result:

```json
"highlight": {
  "name": [
    "PT100温度<em>传</em><em>感</em><em>器</em> LoRaWAN<em>传</em><em>感</em><em>器</em> 环境监测<em>传</em><em>感</em><em>器</em>"
  ]
}
```

---

_最后编辑于 2021 年 03 月 04 日 19:15:33_

[返回目录](../menu.md)
