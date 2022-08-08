package main
import "testing"

func TestMain(t *testing.T) {

    var v int
    v = len(divby(3,30))
    if v != 9 {
	t.Error("Expected 9, got", v)
    }
}