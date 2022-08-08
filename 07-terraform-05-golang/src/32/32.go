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