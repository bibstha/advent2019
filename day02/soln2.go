package main

import (
	"fmt"
	"io/ioutil"
	"strconv"
	"strings"
)

func check(e error) {
	if e != nil {
		panic(e)
	}
}

func fetchInput() []int {
	data, e := ioutil.ReadFile("input")
	check(e)

	mem := strings.Split(strings.TrimSpace(string(data)), ",")
	var memI = make([]int, len(mem))

	for i, val := range mem {
		a, _ := strconv.Atoi(val)
		memI[i] = a
	}

	return memI
}

func calcNounAndVerb(noun int, verb int) int {
	a := fetchInput()
	a[1], a[2] = noun, verb

	for i := 0; ; i += 4 {
		opCode := a[i]
		if opCode == 1 {
			a[a[i+3]] = a[a[i+1]] + a[a[i+2]]
		} else if opCode == 2 {
			a[a[i+3]] = a[a[i+1]] * a[a[i+2]]
		} else if opCode == 99 {
			return a[0]
		} else {
			return 0
		}
	}
}

func main() {
	// part1
	fmt.Println(calcNounAndVerb(12, 2))

out:
	// part2
	for i := 0; i <= 99; i++ {
		for j := 0; j <= 99; j++ {
			if calcNounAndVerb(i, j) == 19690720 {
				fmt.Println(100*i + j)
				break out
			}
		}
	}
}
