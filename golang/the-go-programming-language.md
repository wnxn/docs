## Typo

1. P175 7.3.3 
```
complie error: io.Writer lacks Close method
```

```
complie error: io.Writer lacks Close and Read methods
```

## Q & A

### Chapter7 Interfaces

1. 具体类型的值类型可以赋给接口类型吗？

    答：不可，必须传地址

2. 指针类型可以调用值接收者方法和指针接受者方法，值类型只能调用值接受者方法？

    答：是的。但是注意值类型的变量可以通过隐式转换调用 Value Receiver 和 Pointer Receiver

3. 值接受者方法只能对结构体读，指针接受者方法可读写？

    答：是的

4. 验证 nil 接口值与 dysfunctional value
```
type book interface{
    GetName()string
}

type dict struct{
    name string
}

func (d *dict)GetName()string{
    return d.name
}

func test(){
    var i1 book = dict{"oxford dict"}
    var i2 book = dict{"oxford dict"}
    i1 == i2 //  SHOULD true

    var d1 dict := dict{"oxford dict"}
    var d2 dict := dict{"oxford dict"}
    i1,i2 = d1,d2
    i1 != i2 // SHOULD true, point different
}
```