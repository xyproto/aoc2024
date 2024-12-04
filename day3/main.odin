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

	sum: u128

	for line in strings.split(fileAsString, "mul(") {
		fmt.printf("line: %s: ", line)
		if !strings.contains(line, ")") {
			fmt.println("invalid, must contain at least one )")
			continue
		}
		s := strings.split(line, ")")[0]
		if len(s) < 3 {
			fmt.println("invalid, too short")
			continue
		}
		if strings.count(s, ",") != 1 {
			fmt.println("invalid, expression contain only one ,")
		}
		result := multiply_if_possible(s)
		if result == 0 {
			fmt.println("result was zero")
			continue
		}
		fmt.printfln("OK! Got %d", result)
		sum += u128(result)
	}

	fmt.printfln("got sum: %d", sum)
}

multiply_if_possible :: proc(s: string) -> u128 {
	for r in s {
		if !valid_rune(r) {
			return 0 // contains an invalid rune
		}
	}
	a, b, valid := get_numbers(s)
	if valid {
		//fmt.printfln("%s is valid, and contains %d and %d", s, a, b)
		return a * b
	} else {
		fmt.printfln("%s is invalid, so far", s)
	}
	return 0
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

get_numbers :: proc(s: string) -> (u128, u128, bool) {
	// has the right structure, just need to extract the numbers
	first, _, second := strings.partition(s, ",")
	if len(first) == 0 || len(first) > 3 {
		return 0, 0, false
	}
	if len(second) == 0 || len(second) > 3 {
		return 0, 0, false
	}
	a, ok1 := strconv.parse_u128_maybe_prefixed(first)
	b, ok2 := strconv.parse_u128_maybe_prefixed(second)
	if !ok1 || !ok2 {
		return a, b, false
	}
	return a, b, true
}
