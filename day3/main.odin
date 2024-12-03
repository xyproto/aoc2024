package main

import "core:fmt"
import "core:math"
import "core:os"
import "core:slice"
import "core:strconv"
import "core:strings"

main :: proc() {
	data, ok := os.read_entire_file("input", context.allocator)
	if !ok {
		fmt.println("could not read the input file")
		return
	}
	defer delete(data, context.allocator)
	fileAsString := string(data)

	safecounter := 0

	collector: [dynamic]rune
	defer delete(collector)

	//runeCounter := 0

	sum := 0

	for r in fileAsString {
		if valid_rune(r) {

			// if we got an 'm', abandon all letters before this
			if r == 'm' {
				clear(&collector)
				append(&collector, r)
			} else {
				append(&collector, r) // normal letter collection
			}

			// if we got an ")" check if we have a valid expression
			if r == ')' {
				if len(collector) > 6 {
					sum += check_so_far(&collector)
				}
				clear(&collector)
				//fmt.println("cleared")
			}

			//} else {
			//fmt.printfln("%v is invalid, ignored", r)

			// check what we've got so far
			//check_so_far(&collector)

			// clear the rune collector
			//clear(&collector)
			//fmt.println("cleared")
		}

		//runeCounter += 1
		//if runeCounter > 200 {
		//break
		//}
	}

	if len(collector) > 6 {
		sum += check_so_far(&collector)
	}

	fmt.printfln("got sum: %d", sum)
}

check_so_far :: proc(collector: ^[dynamic]rune) -> int {
	s := collector_to_string(collector^)
	a, b, valid := get_numbers(s)
	if valid {
		//fmt.printfln("%s is valid, and contains %d and %d", s, a, b)
		return a * b
	} else {
		fmt.printfln("%s is invalid, so far", s)
	}
	return 0
}

collector_to_string :: proc(collector: [dynamic]rune) -> string {
	b := strings.builder_make()
	for r in collector {
		strings.write_rune(&b, r)
	}
	return strings.to_string(b)
}

valid_rune :: proc(r: rune) -> bool {
	switch r {
	case '0' ..= '9':
		return true
	case 'm', 'u', 'l', '(', ')', ',':
		return true
	}
	return false
}

get_numbers :: proc(s: string) -> (int, int, bool) {
	promising :=
		strings.contains(s, "mul(") && strings.ends_with(s, ")") && strings.count(s, ",") == 1
	if !promising {
		//fmt.printfln("not promising: %s", s)
		fmt.printfln("GOTCHA does not contain the right ingredients: %s", s)
		return -1, -1, false
	}
	promising = strings.index(s, "mul(") < strings.index(s, ",") && strings.index(s, ",") < strings.index(s, ")")
	if !promising {
		fmt.printfln("GOTCHA wrong order: %s", s)
		return -1, -1, false
	}
	if strings.contains(s, "(,") || strings.contains(s, ",)") { 	// missing numbers
		fmt.printfln("GOTCHA missing numbers: %s", s)
		return -1, -1, false
	}
	expression := s
	if strings.index(s, "mul(") != 0 {
		i := strings.index(s, "mul(")
		expression = strings.cut(s, i)
	}
	// has the right structure, just need to extract the numbers
	first, _, last := strings.partition(expression, ",")
	_, _, firstNumber := strings.partition(first, "(")
	secondNumber := strings.trim_right(last, ")")
	a := strconv.atoi(firstNumber)
	b := strconv.atoi(secondNumber)
	return a, b, true
}
