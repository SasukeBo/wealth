# MongoDB Getting Started

> 快速学习 mongodb 的基本概念和使用

mongodb 是一款 NoSQL 数据库，将数据存储为单独的文件。

## 文档数据库

MongoDB 中的记录是一个文档，它是由字段和值对组成的数据结构。MongoDB 文档类似于 JSON 对象。字段的值可以包括其他文档，数组和文档数组。

使用文档的优点是：

- 文档（即对象）对应于许多编程语言中的内置数据类型。
- 嵌入式文档和数组减少了对昂贵连接的需求。
- 动态模式支持流畅的多态性。

### 集合/视图/按需实例化的视图

MongoDB 将文档存储在集合中，类似于关系型数据库中的表。

## 主要特性

### 高性能

MongoDB 提供高性能的数据持久化：

- 对嵌入式数据模型的支持减少了数据库系统上的 I/O 操作。
- 索引支持更快的查询，并且可以包含来自嵌入式文档和数组的键。

### 丰富的查询语言

支持数据聚合、文本搜索和地理空间查询。
SQL 到 MongoDB 的映射图
SQL 到聚合的映射图

### 高可用

MongoDB 的复制工具称为副本集。它提供：

- 自动故障转移
- 数据冗余

副本集是一组维护相同数据集合的 mongodb 实例，提供了冗余和提高了数据可用性。

### 水平拓展

MongoDB 提供水平可伸缩性作为其核心功能的一部分。

- 分片将数据分布在一个集群的机器上

### MongoDB 支持多种存储引擎

- WiredTiger 存储引擎
- 内存存储引擎

## 使用 Docker 运行 MongoDB

- 启动容器

```sh
docker run -d --name mongodb -p 27017:27017  \
  --network mongo_test_network \
  -e MONGO_INITDB_ROOT_USERNAME=sasukebo \
  -e MONGO_INITDB_ROOT_PASSWORD=123456 \
  mongo
```

- 使用客户端连接

```sh
docker run -d --name mongoclient -p 3000:3000 \
  --network mongo_test_network \
  -e MONGO_URL=mongodb://sasukebo:123456@mongodb:27017/ \
  mongoclient/mongoclient
```

- 直接在容器内通过 shell 连接

```sh
docker exec -it mongodb bash

# 在容器内shell中运行客户端 mongo将自动连接到test数据库
mongo --host localhost \
  -u sasukebo -p 123456 \
  --authenticationDatabase admin \
  test
```

- 选择自己的数据库

```shell
# 在 mongo shell 中执行 db 来查看当前连接的数据库
db
#=> test

# 在 mongo shell 中运行 use example 将切换至 example 数据库
# 无需提前创建，当第一次向该不存在的数据库中插入数据时，mongo会自动
# 创建一个数据库
use example
db
#=> example
```

# 数据库和集合

MongoDB 将 BSON 文档（即数据记录）存储在集合中。

## 数据库

在 MongoDB 中，文档集合存储在数据库中，创建数据库只需要切换至不存在的数据库并向其插入一条数据，MongoDB 则会自动创建该数据库。

```sh
use myNewDB
db.myNewColleciton1.intertOne({ x: 1})
```

`insertOne()` 操作将会同时创建数据库`myNewDB`和集合`myNewCollection1`。

### 显式的创建数据集合

`db.createColletion()` 方法将会显式的创建一个集合，一般情况下，向一个不存在的集合插入一条数据将会创建这个不存在的集合。显式创建可以设置最大大小或文档验证规则等。

### 文档验证

默认情况下，集合不要求其文档具有相同的模式，即单个集合中的文档不需要具有相同的字段集。
从 MongoDB 3.2 开始，可以在更新和插入操作期间对集合强制执行文档验证规则。

### 唯一标识符

集合被分配了一个不变的 UUID。

---

_最后编辑于 2021 年 04 月 20 日 17:58:09_

[返回目录](./menu.md)
