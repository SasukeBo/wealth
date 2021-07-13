# 分布式 ID 设计

> 记录如何设计一种在分布式场景高可用的 ID 生成服务。

## 调研

- 淘宝商品 ID 示例
  629751074708
  619356664897
  https://detail.tmall.com/item.htm?id=619356664897

- 京东商品 ID 示例
  100005558660
  100020129954
  100002982786

## 方案

目标 ID 样式：长度 12 位，纯数字

### 实现原理

时间戳，号段，redis 单线程原子自增特性

- 时间戳

标准 timestamp 长度为 13 位，如果用来作为 ID 的一部分则过长。

```js
new Date('2021-06-11T00:00:00Z').getTime()
// => 1623369600000
```

加入 timestamp 的目的也是为了保证一定时间范围内的唯一性，但我们不需要这么长的时间戳，可以通过和森友会上线日期做差值来取得时间的唯一性，或者是杭州森友会成立日期等。

- 号段

考虑到时间戳的连续性

```golang
package main

import (
	"fmt"
	"time"
)

func main() {
	t := time.Date(2021, time.June, 1, 0, 0, 0, 0, time.UTC)  // 上线日 2021-07-01
	t2 := time.Date(2121, time.June, 1, 0, 0, 0, 0, time.UTC) // 一百年后
	t3 := time.Date(3021, time.June, 1, 0, 0, 0, 0, time.UTC) // 一千年后
	now := time.Now()
	timeStamp := now.Sub(t)
	timeStamp2 := t2.Sub(t)
	timeStamp3 := t3.Sub(t)
	fmt.Println(int64(timeStamp / time.Hour)) // 699
	fmt.Println(int64(timeStamp2 / time.Hour)) // 876576
	fmt.Println(int64(timeStamp3 / time.Hour)) // 2562047
}
```

从上面可以看到，即时是一千年以后的时间戳，其长度也仅需要 7 位，

---

_2021 年 07 月 02 日 10:41:20_

[返回目录](./menu.md)
