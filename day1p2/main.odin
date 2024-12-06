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

	a: [dynamic]int
	defer delete(a)

	b: [dynamic]int
	defer delete(b)

	it := string(data)
	for line in strings.split_lines_iterator(&it) {
		head, _, tail := strings.partition(line, "   ")
		append(&a, strconv.atoi(head))
		append(&b, strconv.atoi(tail))
	}

	slice.sort(a[:])
	slice.sort(b[:])

	shortest := len(a)
	if len(b) < shortest {
		shortest = len(b)
	}

	result := 0

	for i in 0 ..< shortest {
		left := a[i]
		right := b[i]
		result += left * slice.count(b[:], left)
	}

	fmt.println(result)
}
