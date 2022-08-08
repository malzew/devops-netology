package main
import "testing"

func TestMain(t *testing.T) {

    var v float64
    v = meterstofeet (3)
    if v != 9.84 {
	t.Error("Expected 3m = 9.84f, got", v)
    }
}