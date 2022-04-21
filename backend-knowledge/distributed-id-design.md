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

redis key id-srv-pod-1 005

rpc get id
random step =5
 100000 *1000 + 005 = id
random step = 9

if key > 999 {
	db get id range
}

	id-srv pod 1   100003 000 random 1-10 
	id-srv pod 2	 100005 000
	id-srv pod 3   100004 0000


	id 表

	- id auto_increcement
	- 时间

	[1,3,5,6, 19,23,100,150] 0 单调递增 但是不连续

	id 转换 打乱顺序

	1 9 8 0 7 9 0 7 8 5 7
	9 0 9 7 5

ip 一段时间内  404

dao.GetProduct

id 1000000001

db.middleware

- 打乱可恢复 且唯一

---

_2021 年 07 月 02 日 10:41:20_

[返回目录](./menu.md)
