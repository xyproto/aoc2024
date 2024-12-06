package main

import "core:bytes"
import "core:fmt"
import "core:os"
import "core:slice"
import "core:strconv"
import "core:strings"

overlap :: proc(a, b: []int) -> bool {
	for x in a {
		for y in b {
			if x == y {
				return true
			}
		}
	}
	return false
}

valid :: proc(numbers: []int, before_rules, after_rules: map[int][dynamic]int) -> bool {
	for x, i in numbers {
		before := numbers[:i]
		after := numbers[i+1:]
		mustcomebefore := before_rules[x][:]
		mustcomeafter := after_rules[x][:]
		if overlap(before, mustcomeafter) {
			fmt.printfln("%d has numbers before (%v) that must come after to be valid (%v)", x, before, mustcomeafter)
			return false // not valid
		}
		if overlap(after, mustcomebefore) {
			fmt.printfln("%d has numbers after (%v) that must come before to be valid (%v)", x, after, mustcomebefore)
			return false // not valid
		}
	}
	return true
}

main :: proc() {
	filename: string : "input"
	file_as_bytes, ok := os.read_entire_file_from_filename(filename)
	if !ok {
		fmt.printfln("error: could not read %s", filename)
		return
	}

	lines := strings.split(string(bytes.trim_space(file_as_bytes)), "\n")

	before_rules := make(map[int][dynamic]int)
	after_rules := make(map[int][dynamic]int)

	for line in lines {
		if strings.contains(line, "|") {
			numberStrings := strings.split_n(line, "|", 2)
			if len(numberStrings) == 2 {
				a := strconv.atoi(numberStrings[0])
				b := strconv.atoi(numberStrings[1])
				if len(after_rules[a]) == 0 {
					after_rules[a] = [dynamic]int{b}
				} else {
					append(&after_rules[a], b)
				}
				if len(before_rules[b]) == 0 {
					before_rules[b] = [dynamic]int{a}
				} else {
					append(&before_rules[b], a)
				}
			}
		}
	}

	for e, xs in before_rules {
		fmt.printfln("%d must come before %v", e, xs)
	}

	for e, xs in after_rules {
		fmt.printfln("%d must come after %v", e, xs)
	}

	sum := 0

	for line in lines {
		if strings.contains(line, ",") {
			numberStrings := strings.split(line, ",")
			numbers := make([]int, len(numberStrings))
			for numberString, i in numberStrings {
				numbers[i] = strconv.atoi(numberString)
			}
			fmt.printfln("numbers: %v", numbers)
			if valid(numbers, before_rules, after_rules) {
				fmt.println("is valid")
				center_index := (len(numbers)-1)/2
				fmt.printfln("center: %d", numbers[center_index])
				sum += numbers[center_index]
			}
		}
	}

	fmt.printfln("sum: %d", sum)
}
