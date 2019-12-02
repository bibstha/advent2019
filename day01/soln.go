package main

import (
	"bufio"
	"fmt"
	"log"
	"os"
	"strconv"
	"strings"
)

func weight(mass int32) int32 {
	w := (mass / 3) - 2
	if w <= 0 {
		return 0
	}

	return w + weight(w)
}

func main() {
	test := `12
14
1969
100756`
	debug := false

	var sum int32

	file, err := os.Open("input")
	if err != nil {
		log.Fatal(err)
	}
	defer file.Close()

	var scanner *bufio.Scanner

	if debug {
		scanner = bufio.NewScanner(strings.NewReader(test))
	} else {
		scanner = bufio.NewScanner(file)
	}

	for scanner.Scan() {
		mass, err := strconv.ParseInt(scanner.Text(), 10, 32)
		if err != nil {
			log.Fatal(err)
		}

		w := weight(int32(mass))
		sum += w
		if debug {
			fmt.Printf("Weight is %v\n", w)
		}
	}

	fmt.Printf("Total weight is %v\n", sum)
}
