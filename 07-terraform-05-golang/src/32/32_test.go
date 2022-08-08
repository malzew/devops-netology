package main
import "testing"

func TestMain(t *testing.T) {

    var v int
    v = mininslice ([]int{23,2,3,4,99,1})
    if v != 1 {
	t.Error("Expected 1, got", v)
    }
}