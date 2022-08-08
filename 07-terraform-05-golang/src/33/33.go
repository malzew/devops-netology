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