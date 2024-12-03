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

	sum: u128

	enabled := true

	for line in strings.split(fileAsString, "mul(") {
		fmt.printf("line: %s: ", line)

		if !strings.contains(line, ")") { // neither mul( nor do() nor don't()
			fmt.println("invalid, must contain at least one )")
			continue
		}

		s, _, tail := strings.partition(line, ")")

		if len(s) >= 3 { // at least a digit, a comma and a digit
			fmt.printf("mul(%s) == ", s)
			if strings.count(s, ",") != 1 {
				fmt.println("invalid, expression contain only one ,")
			}
			result := multiply_if_possible(s)
			if result == 0 {
				fmt.println("result was zero")
				//continue
			}
			fmt.printfln("%d, enabled=%v", result, enabled)

			if enabled {
				sum += u128(result)
			}
		}

		for i in 0 ..< len(tail) {
			if strings.has_prefix(tail[i:], "do()") {
				enabled = true
			} else if strings.has_prefix(tail[i:], "don't()") {
				enabled = false
			}
		}

		fmt.printfln("tail: %s, enabled=%v", tail, enabled)

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
