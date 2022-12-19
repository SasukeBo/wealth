# Defer执行流程

```go
func main() {
  defer func() {
    recover()
  }()
  panic("error")
}
```
执行过程：
- 运行时调用deferproc 来定义一个延迟调用对象
- 运行时调用gopanic产生panic
- 函数main结束前，运行时调用deferreturn来完成defer定义的函数调用。

deferproc根据defer关键字后定义的函数以及参数大小来定义一个延迟执行的函数。
并将延迟执行函数挂载当前G的_defer链表上。

defer是压栈式的_defer链表对象，绑定在当前的Goroutine上。

defer创建过程

从全局sched上摘取缓存到 p 的_defer池，再从p的_defer池摘取defer到当前g上。

defer使用过后，将被释放，如果是直接分配的内存，则不作处理，否则将defer的内容清零并返回到p的deferpool上。

**作用域**
函数返回之前运行

与计算参数，defer调用时，会拷贝defer的参数值，如果传递的是匿名函数，则拷贝函数指针
