# JsonB 学习笔记

- [8.14 JSON 类型](http://www.postgres.cn/docs/12/datatype-json.html)
- [9.15 JSON 函数和操作符](http://www.postgres.cn/docs/12/functions-json.html)

JSON 数据类型是用来存储 JSON 数据的，这种数据也可以被存储为 text，但是 JSON 数据类型的优势在于能强制要求每个被存储的值符合 JSON 规则。

## JSON 与 JSONB

PostgreSQL 提供两种存储 JSON 的数据类型：json 和 jsonb

json 与 jsonb 数据类型接受几乎完全相同的值集合作为输入。主要的实际区别之一是效率。

- json 数据类型存储输入文本的精准拷贝，处理函数必须在每次执行时重新解析该数据。
- jsonb 数据被存储在一种分解好的二进制格式中，它在输入时要稍微慢一点，因为需要做附加的转换。
- jsonb 支持索引，而 json 不支持。
- json 是输入文本的精准拷贝，其会保存在语法上不明显的、存在于记号之间的多余的空格，以及对象的排列顺序，而且，当同一个键出现多次，所有的键值都会被保存下来，但是处理函数只会把最后一个键值对作为处理对象。

_除非特殊需要，一般都存储为 jsonb_

### JSON 包含和存在

- JSON 包含操作符

```sql
-- 简单的标量/基本值只包含相同的值：
SELECT '"foo"'::jsonb @> '"foo"'::jsonb;

-- 右边的数字被包含在左边的数组中：
SELECT '[1, 2, 3]'::jsonb @> '[1, 3]'::jsonb;

-- 数组元素的顺序没有意义，因此这个例子也返回真：
SELECT '[1, 2, 3]'::jsonb @> '[3, 1]'::jsonb;

-- 重复的数组元素也没有关系：
SELECT '[1, 2, 3]'::jsonb @> '[1, 2, 2]'::jsonb;

-- 右边具有一个单一键值对的对象被包含在左边的对象中：
SELECT '{"product": "PostgreSQL", "version": 9.4, "jsonb": true}'::jsonb @> '{"version": 9.4}'::jsonb;

-- 右边的数组不会被认为包含在左边的数组中，
-- 即使其中嵌入了一个相似的数组：
SELECT '[1, 2, [1, 3]]'::jsonb @> '[1, 3]'::jsonb;  -- 得到假

-- 但是如果同样也有嵌套，包含就成立：
SELECT '[1, 2, [1, 3]]'::jsonb @> '[[1, 3]]'::jsonb;

-- 类似的，这个例子也不会被认为是包含：
SELECT '{"foo": {"bar": "baz"}}'::jsonb @> '{"bar": "baz"}'::jsonb;  -- 得到假

-- 包含一个顶层键和一个空对象：
SELECT '{"foo": {"bar": "baz"}}'::jsonb @> '{"foo": {}}'::jsonb;
```

- JSON 存在操作

```sql
-- 字符串作为一个数组元素存在：
SELECT '["foo", "bar", "baz"]'::jsonb ? 'bar';

-- 字符串作为一个对象键存在：
SELECT '{"foo": "bar"}'::jsonb ? 'foo';

-- 不考虑对象值：
SELECT '{"foo": "bar"}'::jsonb ? 'bar';  -- 得到假

-- 和包含一样，存在必须在顶层匹配：
SELECT '{"foo": {"bar": "baz"}}'::jsonb ? 'bar'; -- 得到假

-- 如果一个字符串匹配一个基本 JSON 字符串，它就被认为存在：
SELECT '"foo"'::jsonb ? 'foo';
```
