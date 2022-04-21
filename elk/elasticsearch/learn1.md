# Elasticsearch 入门

## 基本概念

### JSON 文档

- 一篇文档包含一系列字段，类似关系数据库中的一条记录。
- json 文档格式灵活，不需要预先定义格式
  - 字段的类型可以指定或通过 Elasticsearch 自动推算
  - 支持数组 支持嵌套

### 文档的元数据

- 元数据，用于标注文档的相关信息

  - \_index 文档所属的索引名
  - \_type 文档所属的类型名 已经被废弃了，目前只能创建"\_doc"类型的索引
  - \_id 文档唯一 ID
  - \_source 文档的原始 JSON 数据
  - \_version 文档的版本信息
  - \_score 相关性打分，针对具体查询

- index 索引是文档的容器，是一类文档的结合

  - index 体现了逻辑空间的概念
  - shard 体现了物理空间的概念，索引中的数据分散在 Shard 中

- mapping 定义文档字段的类型
- setting 定义不同的数据分布

### 索引的不同于以

作为动词，索引的意思是指将文档写入 ES
作为名词，可能是 B 树索引、倒排索引

### 分布式 高可用

Master eligible 节点是可以选举为 master 节点的节点，只有 master 节点允许修改集群信息
Data 节点负责保存分片数据
Coordinating 节点负责处理 Client 请求

### 分片

主分片，用来解决数据水平扩展问题。主分片数在索引创建时指定，后续不允许修改，除非 Reindex
副本分片，实际是主分片的拷贝。

- create 支持 post 和 put，对应 id 是自动生成还是指定
- \_bulk 支持在一次请求中对多个索引执行多种操作
- \_mget 批量读取多个索引的多个文档
- \_msearch 批量查询

所有的批量操作都是支持多索引的操作

### 倒排索引

图书中的目录页是正排索引

倒排索引就是文档单次到文档 id 的映射。

- 单词词典 记录所有文档的单词 B+树或哈希拉链法实现，满足高性能的插入与查询
- 倒排列表 记录单词对应的文档集合，由倒排索引项组成
  - 文档 id
  - 词频
  - 位置
  - 偏移

### 分词器 analysis

- analysis 文本分析，分词
- analysis 通过 analyzer 实现

#### 在 Mapping 中配置自定义的 Analyzer

- 可以在自己的索引中，使用 tokenizer 和 filter、char_filter 组合成自己想要的 analyzer
- tokenizer，char_filter 也都可以自己定义

创建索引并声明 analyzer

```json
// PUT my_index
{
  "setting": {
    "analysis": {
      "analyzer": {
        "my_custom_analyzer": {
          "type": "custom",
          "char_filter": ["emoticons"],
          "tokenizer": "punctuation",
          "filter": ["lowercase", "english_stop"]
        }
      },
      "tokenizer": {
        "punctuation": {
          "type": "pattern",
          "pattern": "[ .,!?]"
        }
      },
      "char_filter": {
        "emoticons": {
          "type": "mapping",
          "mappings": [":) => _happy_", ":( => _sad_"]
        }
      },
      "filter": {
        "english_stop": {
          "type": "stop",
          "stopwords": "_english_"
        }
      }
    }
  }
}
```

检查自定义的 analyzer

```json
// POST my_index/_analyze
{
  "analyzer": "my_custom_analyzer",
  "text": "I'm a :) person, and you?"
}
```

### 使用查询表达式

- match
  多个单词的匹配默认的是 or 关系

### Index Template 和 Dynamic Template

- index template

按照一定的规则定义索引的 mapping，创建索引结构的模板，创建索引可以指定多个索引模板。

```json
// PUT /_template/template_test
{
  "index_patterns": ["test*"], // 匹配以test开头的索引
  "order": 1,
  "settings": {
    "number_of_shards": 1, // 分片数1
    "number_of_replicas": 2 // 副本数2
  },
  "mappings": {
    "date_detection": false, // 日期检测关闭
    "numeric_detection": true // 数字检测打开
  }
}
```

按照模板顺序，从顺序低的开始生效，后生效的覆盖先生效的模板配置。
插入一条`test*`开头的文档数据：

```json
PUT test_sasuke/_doc/1
{
  "someNumber": "1",
  "someDate": "2022-04-20 13:56:16"
}
```

- dynamic template

动态模板是定义在某个索引的 mapping 中的

```json
PUT my_index
{
  "mappings": {
    "dynamic_templates": [
      {
        "strings_as_boolean": {
          "match_mapping_type": "string",
          "match": "is*",
          "mapping": {
            "type": "boolean"
          }
        }
      },
      {
        "strings_as_keywords": {
          "match_mapping_type": "string",
          "mapping": {
            "type": "keyword"
          }
        }
      }
    ]
  }
}
```

尝试写入文档

```json
PUT my_index/_doc/1
{
  "firstName": "Ruan",
  "isVIP": "true"
}
```

另一个例子

```json
PUT my_index
{
  "mappings": {
    "dynamic_templates": [
      {
        "full_name": {
          "path_match": "name.*",
          "path_unmatch": "*.middle",
          "mapping": {
            "type": "text",
            "copy_to": "full_name"
          }
        }
      }
    ]
  }
}

PUT my_index/_doc/1
{
  "name": {
    "first": "John",
    "middle": "Winston",
    "last": "Lennon"
  }
}
```

### Elasticsearch 聚合分析简介

集合的分类

- Bucket 一些列满足特定条件的文档集合
- Metric 一些数学运算，可以对文档字段进行统计分析
- Pipeline 对其他的集合结果进行二次聚合
- Matrix 支持对多个字段的操作并提供一个结果矩阵

### 总结

- 字段类型修改必须走 reindex，无法直接改类型
