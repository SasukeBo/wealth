# 数据库和集合

## 视图

### 创建视图

[db.createView()](https://docs.mongodb.com/manual/reference/method/db.createView/#db.createView)

```js
// 创建一个视图，需要提供视图名称，数据来源，流水线阶段列表，可选配置
db.createView(<view>, <source>, <pipeline>, <options>)
```

该方法是下面指令的简写：

```js
db.runCommand( { create: <view>, viewOn: <source>, pipeline: <pipeline>, collation: <collation> } )
```

### 视图的特性

## 只读

视图是只读的，通过视图进行写操作会报错
视图仅支持以下操作：

- db.view.find() 查找所有满足条件的记录
- db.view.findOne() 查找一条满足条件的记录
- db.view.aggregate()
- db.view.count() 统计满足条件的记录
- db.collection.distinct() 去重查询字段

## 索引使用和排序操作

- 视图使用其上游集合的索引
- 由于索引是基于集合的，所以不能基于视图对索引进行写操作。也不能获取视图的索引列表。

## Project 限制

视图不支持一些 projection

## 视图不可重命名

## 操作视图

要删除视图，使用视图上的`db.collection.drop()`方法。
若要修改，可以通过删除后重建的方式。也可以使用 collMod 方法。

# 按需物化视图

该特性主要是通过`$merge`流水线阶段实现，该阶段可以将流水线结果导向已存在的集合，合并而不是完全取代集合中的数据。

## Example

```js
updateMonthlySales = function (startDate) {
  db.bakesales.aggregate([
    { $match: { date: { $gte: startDate } } },
    {
      $group: {
        _id: { $dateToString: { format: '%Y-%m', date: '$date' } },
        sales_quantity: { $sum: '$quantity' },
        sales_amount: { $sum: '$amount' }
      }
    },
    { $merge: { into: 'monthlybakesales', whenMatched: 'replace' } }
  ])
}
```

此处定义了一个函数，用于物化视图，实际数据来自于`bakesales`集合，流水线包括三个阶段：

- `match` 过滤了集合中的数据，仅保留了大于`startDate`时间的数据。
- `group` 将数据分组聚合，`_id`字段通过 `$dateToString`将日期处理为月份字符串，统计了符合该月的数据的销售量和总额。
- `$merge` 阶段将以上两个阶段的数据写入了 `monthlybakesales`集合，该集合就是按需物化出的视图。写入策略是当`_id`匹配时，采用替换的方式将数据更新。

[官方例子](https://docs.mongodb.com/manual/core/materialized-views/#example)

# 封顶集合

封顶集合是一个固定大小的集合，支持基于插入顺序的高吞吐量插入和查询操作。
封顶集合的工作方式有点类似于循环缓冲区，当写入数据充满了分配的存储空间时，新的数据将会覆盖最旧的数据。

## 表现

### 插入顺序

封顶集合保留了插入数据时的顺序，因此查询数据时不需要通过索引，也因此它可以支持高吞吐量的数据插入。

### 自动清除最旧的数据

为了给新数据开辟存储空间，封顶集合会自动删除最旧的数据。
该特性有以下潜在的使用场景：

- 用于存储系统日志，由于不需要索引，向封顶集合中插入日志数据的速度近似于直接向文件系统写入数据。并且具有先进先出的特性，保存了事件发生顺序。
- 用于缓存小量数据

### \_id index

封顶集合具有\_id 字段，并且该字段上默认建有索引。

## 约束与建议

### 更新操作

如果你计划更新封顶集合中的数据，请创建一个索引，这样做可以避免全集扫描带来的开销。

### 文档大小

如果更新或替换操作改变了文档的大小，那么这个操作将会失败。

### 删除操作

你不能删除封顶集合中的文档，只能通过全部删除并重建的方式来删除其中的某些文档。
使用集合的`drop()`方法去删除所有数据。

### 不支持分片

### 查询效率

使用自然顺序来有效的检索集合最近插入的元素，类似于`tail`一个日志文件。

### 不支持将聚合管道`$out`操作的结果写入封顶集合

## 使用

### 创建一个封顶集合

必须使用`db.createCollection()`方法显式的创建封顶集合。

```js
db.createCollection('log', { capped: true, size: 100000, max: 5000 })
```

封顶集合最小容量为 4096 字节，并且，mongodb 会为用户分配满足设定大小且为 256 的整数倍的数值的存储空间。例如，`size`设定为 `100000`，实际分配应该是`100096`。
除此以为，还可以通过配置`max`来限制文档存储数量。
**注意** `size`字段是必须指定的，虽然设定了最大文档数量，但是 mongo 清除旧数据的时机是依据 size 来判断的。

### 查询一个封顶集合

查询结果默认按照插入顺序排序，如果需要按照插入顺序反向输出，则通过`$natural`设置为`-1`来完成。

### Check if a Collection is Capped

```js
db.collection.isCapped()
```

### Convert a Collection to Capped

mongo 支持将已有的集合转换为封顶集合

```js
db.runCommand({ convertToCapped: 'mycoll', size: 100000 })
```

_最后编辑于 2020 年 12 月 15 日 16:34:41_

[返回目录](./menu.md)
