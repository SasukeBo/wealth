## TTL

指定属性的存活时间

- 对于点而言，存活时间结束则被删除。如果是多 tag 的点，则该 tag 携带的属性全部删除，点不被删除。
- 对于边而言，TTL 结束直接删除。

## Tag

1. 创建

```sql
CREATE TAG IF NOT EXSTS player(name string, age int);
```

2. DROP

删除所有点上的指定 tag

```sql
DROP TAG IF EXISTS no_property;
```

3. DELETE

删除指定点上的指定 tag

```sql
DELETE TAG no_property FROM "no1";
DELETE TAG * FROM "no1";
```

## Edge type 边类型

- Edge type 与 tag 同名会引发这种错误。
  `ERROR: Schema with same name exists`
- 一个边只能有一个 Edge type，删除 Edge type 后用户无法访问这个 Edge type 的所有边。

1. 创建

Edge type 创建与 Tag 类似。

```sql
CREATE EDGE IF NOT EXISTS no_property_edge();
CREATE EDGE IF NOT EXISTS follow(degree int);
```

2. 删除
3. 修改

被指定 TTL 的属性无法进行类型的修改

fixed_string(N)，超出长度的值会被截断，而不报错。

## 边

```sql
insert edge follow (degree) values "player01" -< >
```
