package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"
import "core:slice"
import "core:math"

main :: proc() {
	data, ok := os.read_entire_file("input", context.allocator)
	if !ok {
		fmt.println("could not read the input file")
		return
	}
	defer delete(data, context.allocator)
	fileAsString := string(data)

	safecounter := 0

	for line in strings.split_lines_iterator(&fileAsString) {
		numbersInLine: [dynamic]int
		defer delete(numbersInLine)
		for stringNumber in strings.split(line, " ") {
			append(&numbersInLine, strconv.atoi(stringNumber))
		}
		//fmt.print(numbersInLine)
		if safe(numbersInLine) {
			safecounter += 1
			//fmt.println(" safe")
		} else {
			// The pretty inefficient, but functional, "Problem Dampener"
			for i in 0..<len(numbersInLine) {
				xs := make([dynamic]int, len(numbersInLine), len(numbersInLine))
				copy(xs[:], numbersInLine[:])
				ordered_remove(&xs, i)
				if safe(xs) {
					safecounter += 1
					break
				}
				delete(xs)
			}
			//fmt.println(" unsafe")
		}
	}

	fmt.printfln("safecounter %d", safecounter)
}

safe :: proc(numbers: [dynamic]int) -> bool {
	prevx := 0
	increasing := true
	foundDirection := false
	for i in 0..<len(numbers) {
		x := numbers[i]

		diff := x - prevx
		prevx = x

		if i == 0 {
			continue
		}

		if !foundDirection {
			if diff < 0 {
				increasing = false
				foundDirection = true
			} else if diff > 0 {
				increasing = true
				foundDirection = true
			}
		}

		if increasing && diff < 0 {
		     return false // unsafe line
		} else if !increasing && diff > 0 {
		     return false // unsafe line
        }

		if math.abs(diff) < 1 || math.abs(diff) > 3 {
			return false // unsafe line
		}

	}
	return true // safe line
}
