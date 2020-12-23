可以比较，也可以不能比较

当 struct 包含不可比较的成员时则不能比较

不可比较的成员包括 Slice、Map 和 Function

```golang
type T struct {
	Name  string
	Age   int
	Hobby map[string]int
}

func main() {
	t1 := T{Name: "hello", Age: 1}
	t2 := T{Name: "hello", Age: 1}
	fmt.Println(t1 == t2) // Invalid operation: t1 == t2 (operator == is not defined on T)
}
```

```golang
type T struct {
	Name  string
	Age   int
  Hobby [1]string
}

func main() {
	t1 := T{Name: "hello", Age: 1}
	t2 := T{Name: "hello", Age: 1}
	fmt.Println(t1 == t2)  // => true
}
```
