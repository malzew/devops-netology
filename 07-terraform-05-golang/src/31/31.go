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
