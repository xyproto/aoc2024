package main

import "core:bytes"
import "core:fmt"
import "core:os"
import "core:strconv"
import "core:strings"

overlap :: proc(a, b: []int) -> (int, bool) {
	for x in a {
		for y in b {
			if x == y {
				return x, true
			}
		}
	}
	return 0, false
}

valid :: proc(numbers: []int, before_rules, after_rules: map[int][dynamic]int) -> bool {
	for x, i in numbers {
		before := numbers[:i]
		after := numbers[i + 1:]
		mustcomebefore := before_rules[x][:]
		mustcomeafter := after_rules[x][:]
		if _, has_overlap := overlap(before, mustcomeafter); has_overlap {
			fmt.printfln(
				"%d has numbers before (%v) that must come after to be valid (%v)",
				x,
				before,
				mustcomeafter,
			)
			return false // not valid
		}
		if _, has_overlap := overlap(after, mustcomebefore); has_overlap {
			fmt.printfln(
				"%d has numbers after (%v) that must come before to be valid (%v)",
				x,
				after,
				mustcomebefore,
			)
			return false // not valid
		}
	}
	return true
}

// swap returns two index in numbers that should be swapped, and if a swap was found
swap :: proc(numbers: []int, before_rules, after_rules: map[int][dynamic]int) -> (int, int, bool) {
	for x, i in numbers {
		before := numbers[:i]
		after := numbers[i + 1:]
		mustcomebefore := before_rules[x][:]
		mustcomeafter := after_rules[x][:]
		if y, overlaps := overlap(before, mustcomeafter); overlaps {
			fmt.println("not valid!")
			fmt.printfln(
				"%d has numbers before (%v) that must come after to be valid (%v)",
				x,
				before,
				mustcomeafter,
			)
			fmt.printfln("rule %d|%d, SWAP!", y, x)
			return y, x, true
		}
		if y, overlaps := overlap(after, mustcomebefore); overlaps {
			fmt.println("not valid!")
			fmt.printfln(
				"%d has numbers after (%v) that must come before to be valid (%v)",
				x,
				after,
				mustcomebefore,
			)
			fmt.printfln("rule %d|%d, SWAP", y, x)
			return y, x, true
		}
	}
	return 0, 0, false
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

			if !valid(numbers, before_rules, after_rules) { 	// only swapping and adding originally invalid numbers

				a, b, should_swap := swap(numbers, before_rules, after_rules)
				for should_swap {
					fmt.printfln("swapping %d and %d", a, b)
					index_a := -1
					index_b := -1
					for x, i in numbers {
						if x == a {
							index_a = i
						} else if x == b {
							index_b = i
						}
						if index_a != -1 && index_b != -1 {
							break
						}
					}
					numbers[index_a] = b
					numbers[index_b] = a

					fmt.printfln("numbers after swapping: %v", numbers)

					a, b, should_swap = swap(numbers, before_rules, after_rules)
				}

				center_index := (len(numbers) - 1) / 2
				fmt.printfln(
					"%v are now valid, adding center number %d",
					numbers,
					numbers[center_index],
				)
				sum += numbers[center_index]
			}
		}
	}

	fmt.printfln("sum: %d", sum)
}
