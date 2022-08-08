# Домашнее задание к занятию "7.5. Основы golang"

С `golang` в рамках курса, мы будем работать не много, поэтому можно использовать любой IDE. 
Но рекомендуем ознакомиться с [GoLand](https://www.jetbrains.com/ru-ru/go/).  

## Задача 1. Установите golang.
1. Воспользуйтесь инструкций с официального сайта: [https://golang.org/](https://golang.org/).
2. Так же для тестирования кода можно использовать песочницу: [https://play.golang.org/](https://play.golang.org/).

*Выполнено*

## Задача 2. Знакомство с gotour.
У Golang есть обучающая интерактивная консоль [https://tour.golang.org/](https://tour.golang.org/). 
Рекомендуется изучить максимальное количество примеров. В консоли уже написан необходимый код, 
осталось только с ним ознакомиться и поэкспериментировать как написано в инструкции в левой части экрана.  

*Выполнено*

## Задача 3. Написание кода. 
Цель этого задания закрепить знания о базовом синтаксисе языка. Можно использовать редактор кода 
на своем компьютере, либо использовать песочницу: [https://play.golang.org/](https://play.golang.org/).

1. Напишите программу для перевода метров в футы (1 фут = 0.3048 метр). Можно запросить исходные данные 
у пользователя, а можно статически задать в коде.

```go
package main

import (
    "fmt"
    "math"
)

func meterstofeet (m float64) float64 {

    return math.Round((m/0.3048)*100)/100

}

func main() {
    fmt.Print("Enter the number of meters: ")
    var input float64
    fmt.Scanf("%f", &input)

    output := meterstofeet(input)

    fmt.Println("Feet: ",output)
}
```

```commandline
$ go run 31.go 
Enter the number of meters: 4
Feet:  13.12
```

1. Напишите программу, которая найдет наименьший элемент в любом заданном списке, например:
   ```
    x := []int{48,96,86,68,57,82,63,70,37,34,83,27,19,97,9,17,}
   ```
   
```go
package main

import "fmt"

func mininslice (xs []int) int {

    min := xs[0]
    for _, v := range xs {
	if min > v {
	    min = v
	}
    }
    return min
}
func main() {

    x := []int{48,96,86,68,57,82,63,70,37,34,83,27,19,97,9,17,}

    min := mininslice(x)
    fmt.Printf("Minimum: %d\n",min)
}
```

```commandline
$ go run 32.go 
Minimum: 9
```

1. Напишите программу, которая выводит числа от 1 до 100, которые делятся на 3. То есть `(3, 6, 9, …)`.

```go
package main

import "fmt"

func divby (div int, max int) [] int {

    var res [] int

    v := div

    for i := 2; v < max; i++ {
	res = append(res,v)
	v = i*div
    }

    return res
}

func main() {

    var result [] int

    result = divby(3,100)

    fmt.Printf("%v\n",result)
}
```

```commandline
$ go run 33.go 
[3 6 9 12 15 18 21 24 27 30 33 36 39 42 45 48 51 54 57 60 63 66 69 72 75 78 81 84 87 90 93 96 99]
```

В виде решения ссылку на код или сам код. 

## Задача 4. Протестировать код (не обязательно).

Создайте тесты для функций из предыдущего задания. 

*Тест для задания 3.1*

```go
package main
import "testing"

func TestMain(t *testing.T) {

    var v float64
    v = meterstofeet (3)
    if v != 9.84 {
	t.Error("Expected 3m = 9.84f, got", v)
    }
}
```

*Тест для задания 3.2*

```go
package main
import "testing"

func TestMain(t *testing.T) {

    var v int
    v = mininslice ([]int{23,2,3,4,99,1})
    if v != 1 {
	t.Error("Expected 1, got", v)
    }
}
```

*Тест для задания 3.3*

```go
package main
import "testing"

func TestMain(t *testing.T) {

    var v int
    v = len(divby(3,30))
    if v != 9 {
	t.Error("Expected 9, got", v)
    }
}
```

---

### Как cдавать задание

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---

