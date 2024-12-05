package main

import "core:bytes"
import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"

main :: proc() {
	filename: string : "input"
	file_as_bytes, ok := os.read_entire_file_from_filename(filename)
	if !ok {
		fmt.printfln("error: could not read %s", filename)
		return
	}

	lines := strings.split(string(bytes.trim_space(file_as_bytes)), "\n")

	for line in lines {
		if strings.contains(line, "|") {
			numberStrings := strings.split_n(line, "|", 2)
			if len(numberStrings) == 2 {
				a := strconv.atoi(numberStrings[0])
				b := strconv.atoi(numberStrings[1])
				fmt.printfln("a: %d, b: %d", a, b)
			}
		} else if strings.contains(line, ",") {
			numberStrings := strings.split(line, ",")
			numbers := make([]int, len(numberStrings))
			for numberString, i in numberStrings {
				numbers[i] = strconv.atoi(numberString)
			}
			fmt.println(numbers)
		}
	}

}
