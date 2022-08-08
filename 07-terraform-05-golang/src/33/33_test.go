package main
import "testing"

func TestMain(t *testing.T) {

    var v int
    v = len(divby(3,30))
    if v != 10 {
	t.Error("Expected 10, got", v)
    }
}