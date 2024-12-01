package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"
import "core:slice"
import "core:sort"
import "core:math"

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

	d: [dynamic]int
	defer delete(d)

	for i in 0..<shortest {
		append(&d, abs(a[i] - b[i]))
	}

	sumOfDiffs := math.sum(d[:])

	fmt.println(sumOfDiffs)
}
