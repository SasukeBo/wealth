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

### 基于全文本的查询

支持的查询

- Match Query / Match Phrase Query / Query String Query
- 特点
  - 索引和搜索时都会进行分词，查询字符串先传递到一个合适的分词器，然后生成一个供查询的词项列表
  - 查询会对输入进行分词
