# Elastic Stack 快速入门

> 本文档将介绍 Elasticsearch、Kibana、Beats 的搭建使用

## 安装 Elasticsearch

Elasticsearch 是一个实时分布式的存储、搜索及分析引擎。它可以被用来做很多事情，但我的学习目的主要是用它来分析系统日志。

### 安装方式

- linux 安装方法

```sh
curl -L -O https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.11.1-linux-x86_64.tar.gz
tar -xzvf elasticsearch-7.11.1-linux-x86_64.tar.gz
cd elasticsearch-7.11.1
./bin/elasticsearch
```

- [使用 docker 安装](./elasticsearch.md)

### 检查安装是否成功

通过向 Elasticsearch 发起 http 请求，来判断是否安装成功：

```sh
curl http://127.0.0.1:9200
```

正常情况下会返回类似如下结果：

```json
{
  "name": "D30GcNh",
  ...
  "tagline": "You Know, for Search"
}
```

## 安装 Kibana

Kibana 是一个转为 Elasticsearch 开发的开源分析可视化平台。有了它，你就可以通过 UI 去搜索存储在 Elasticsearch 中的数据。
官方建议我们将 Kibana 和 Elasticsearch 安装在同一个服务器上，目的是为了查询速度更快，但不是必须这样。

### 安装方式

- linux

```sh
curl -L -O https://artifacts.elastic.co/downloads/kibana/kibana-7.11.1-linux-x86_64.tar.gz
tar xzvf kibana-7.11.1-linux-x86_64.tar.gz
cd kibana-7.11.1-linux-x86_64/
./bin/kibana
```

- [使用 docker 安装](./kibana.md)

安装完成后可以通过 http://localhost:5601 访问 Kibana web 界面。

## 安装 Beats

Beats 是用来收集数据并发送给 Elasticsearch 的客户端，Beats 有很多种，每一种用于收集不同的数据，这里选择 Filebeat 继续学习。

### 安装 Filebeat

- linux

```sh
curl -L -O https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-7.11.1-linux-x86_64.tar.gz
tar xzvf filebeat-7.11.1-linux-x86_64.tar.gz
```

- [使用 docker 安装](./filebeat.md)

---

_最后编辑于 2020 年 12 月 15 日 16:34:41_

[返回目录](./menu.md)

**参考**

- [官方文档 Getting started with the Elastic Stack](https://www.elastic.co/guide/en/elastic-stack-get-started/7.11/get-started-elastic-stack.html)
