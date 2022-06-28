# 深入搜索

## 基于词项和基于全文的搜索

### 基于 Term 的查询

- Term 是表达语义的最小单位，Term 查询不会对输入作分词处理

```json
POST /products/_bulk
{ "index": { "_id": 1} }
{ "productID": "XHDK-A-1293-#fJ3", "desc": "iPhone" }
{ "index": { "_id": 2} }
{ "productID": "KDKE-B-9947-#kL5", "desc": "iPad" }
{ "index": { "_id": 3} }
{ "productID": "JODL-X-1937-#pV7", "desc": "MBP" }
```

尝试如下搜索：

```json
POST /products/_search
{
  "query": {
    "term": {
      "desc": {
        "value": "iPad"
      }
    }
  }
}
```

并不能搜到结果，就是因为 term 搜索不会进行分词处理，而文档索引`iPad`会做小写转化。如果搜索`ipad`就能够命中。

### 复合查询 constant score 转为 filter

- 将 query 转为 filter 忽略 TF-IDF 计算，避免相关性算分的开销
- filter 可以有效利用缓存

```json
POST products/_search
{
  "explain": true,
  "query": {
    "contant_score": {
      "filter": {
        "term": {
          "productID.keyword": "KDKE-B-9947-#kL5"
        }
      }
    }
  }
}
```

### 基于全文本的查询

支持的查询

- Match Query / Match Phrase Query / Query String Query
- 特点
  - 索引和搜索时都会进行分词，查询字符串先传递到一个合适的分词器，然后生成一个供查询的词项列表
  - 查询会对输入进行分词

## 结构化所搜

- 日期、布尔、数字都是结构化数据
- 文本有时候也是结构化数据
- 结构化的数据可以用 term 做精确搜索
- 结构化的搜索结果只有是或否两个值

## 搜索相关性和相关性算法

- 相关性

BM 25 算法，描述一个文档和查询语句的匹配程度，打分的本质是排序。

- 词频

Term Frequency 检索词在文档中出现的频率，检索词出现次数除以文档的总字数
将每个词的 TF 值相加

- 逆文档频率 IDF

Inverse Document Frequency 简单说就是 log(全部文档数/检索词出现过的文档总数)
TF-IDF 本质就是将 TF 求和变成了加权求和

`TF * IDF + TF * IDF + TF * IDF`

## Query&Filtering 与多字符串多字段查询

- query context 会进行相关性的算分
- filter context 不需要算分（yes or no），可以利用缓存，性能更佳

### 条件组合

符合查询 bool query
支持写多个条件子句，并进行组合

- must
- should
- must_not 不贡献算分 属于 filter context
- filter 不贡献算分

bool 查询语法

- 子查询可以任意顺序出现
- 可以嵌套多个查询
- 如果 bool 查询中，没有 must 条件，should 中必须至少满足一条查询

### bool 嵌套

支持嵌套

```json
// POST /products/_search
{
  "query": {
    "bool": {
      "must": {
        "term": {
          "price": "30"
        }
      },
      "should": [
        {
          "bool": {
            "must_not": {
              "term": {
                "avaliable": "false"
              }
            }
          }
        }
      ],
      "minimum_should_match": 1
    }
  }
}
```

布尔查询层级同一级的算分权重相同，子层级之和与当前层级权重相同

### 通过 boosting 的方式增加权重

```json
// POST news/_search
{
  "query": {
    "boosting": {
      "positive": {
        "match": {
          "content": "apple"
        }
      },
      "negative": {
        "match": {
          "content": "pie"
        }
      },
      "negative_boost": 0.5
    }
  }
}
```

对搜索结果不期望出现的内容做 negative_boost 加强

## 单字符串多字段查询 Dis Max Query

dis_max 将算分最高的作为排序依据

## 单字符串多字段查询，Multi Match

- 最佳字段，当字段之间相互竞争，又相互关联，例如 title 和 body 这样的字段，评分来自最匹配字段
- 多数字段
- 混合字段

### 跨字段搜索

单个所搜词要想命中多个字段且是 and 逻辑，multi_match 的 type:most_fields 做不到，虽然可以用 copy_to 解决，但是要额外的存储空间，所以有 type:cross_fields 跨字段搜索。

搜索的优化需要结合用户行为来不断改进

## 综合排序

### function score query

> 可以在查询结束后对每一个匹配的文档进行一系列的重新算分，根据新生成的分数进行排序。

1. 提供了几种默认的计算分值的函数

- `weight` 为每一个文档设置一个简单而不被规范化的权重
- `field value factor` 使用 field 指定字段存储的值来修饰算分，例如将热度、点赞数作为算分的修饰。
  - 可以通过`modifier`参数来指定方法对 field 数值做平滑处理，比如 log1p [log(1+field)]
  - 引入`factor`就会对 field 数值在做一个系数乘积。新的算分 = 老的算分 _ log(1 + factor _ field)
- `random score` 为每一个文档随机一个算分结果
- 衰减函数，以某个字段的值为标准，距离字段值的越近，算分越高
- `script score` 支持自定义脚本算分

2. Boost Mode 和 Max Boost

- Boost Mode

  - Multiply: 算分和函数值的乘积，也是默认模式
  - Sum: 求和
  - Min / Max: 算分和函数值取 最小 / 最大值
  - Replace: 函数值直接取代算分

- Max Boost
  - 可以将函数值限制在最大范围内

### 一致性随机函数

通过 random_score，就可以对搜索结果达到一个随机排序，为每一个用户指定一个 seed 就可以为每个用户呈现不同的随机排序，只要 seed 值不发生变化，用户的多次查询结果排序始终会保持一致。

## Term&Phrase Suggester

### 什么是搜索建议

- 按照用户输入进行推荐
- 输入纠错
- 自动补全

### Elasticsearch Suggester API

> 原理 将输入的文本分解为 token，然后在索引的字典中查找相似的 term 并返回

4 中 suggester

- Term & Phrase
- Complete & Context

1. Term Suggester

每个建议都包含了一个算分，核心思想是，一个词改动多少字符可以和另外一个词一致。提供了很多参数可以控制模糊程度，例如控制最大改动次数的 max_edits 参数。
建议模式：

- Missing 如果索引中存在 term 命中就不进行推荐
- Popular 推荐出现频率更高的词
- Alaways 无论如何都会推荐

2. Phrase Suggester

3. Complete Suggester

自动补全功能，Complete Suggester 对性能的要求比较苛刻，采用不同的数据结构，不是采用倒排索引，而是将分析结果存储为 FST，并完全加载到内存中计算。
FST 只支持基于前缀的查找。

使用上，需要在定义 mapping 时需要对字段指定 completion type。

```json
{
  "mapping": {
    "properties": {
      "title": {
        "type": "completion"
      }
    }
  }
}
```

4. Context Suggester

是 complete 的拓展，结合上下文进行推荐，例如输入“star”，在咖啡相关是 starbucks，电影相关可能是 star wars

## 分页与遍历

### 分布式系统中深度分页的问题

页数越大性能开销越大
