package main

import (
	"fmt"
	"io/ioutil"
	"log"
	"strconv"
	"strings"
)

func value(noun int32, verb int32, a []int32) int32 {
	a[1] = noun
	a[2] = verb

	for i := 0; i < len(a); i += 4 {
		if a[i] == 1 || a[i] == 2 {
			pos1 := a[i+1]
			pos2 := a[i+2]
			pos3 := a[i+3]
			if a[i] == 1 {
				a[pos3] = a[pos1] + a[pos2]
			} else {
				a[pos3] = a[pos1] * a[pos2]
			}
		} else {
			break
		}
	}

	return a[0]
}

func main() {
	data, err := ioutil.ReadFile("input")
	if err != nil {
		log.Fatal(err)
	}

	// Get the data as integer in a slice
	input := strings.Split(strings.TrimSpace(string(data)), ",")
	a := make([]int32, len(input))
	for i, data := range input {
		intval, err := strconv.ParseInt(data, 10, 32)
		if err != nil {
			log.Fatal(err)
		}

		a[i] = int32(intval)
	}

	var val int32
	newa := make([]int32, len(input))

	done := false
	for i := int32(0); i <= 99; i++ {
		for j := int32(0); j <= 99; j++ {
			copy(newa, a)
			val = value(i, j, newa)
			// fmt.Printf("For %v %v = %v\n", i, j, val)
			if val == 19690720 {
				fmt.Printf("%v", 100*i+j)
				done = true
				break
			}
		}
		if done {
			break
		}
	}
}
