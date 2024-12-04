package main

import "core:bytes"
import "core:fmt"
import "core:os"
import "core:strconv"

// undynamic converts a [dynamic]u8 to an []u8 slice
// There are *most likely* easier ways to do this in Odin.
undynamic :: proc(xs: [dynamic]u8) -> []u8 {
	result := make([]u8, len(xs))
	for r, i in xs {
		result[i] = r
	}
	return result
}

get :: proc(bytelines: ^[][]u8, w: int, h: int, x: int, y: int) -> (u8, bool) {
	if x >= 0 && x < w && y >= 0 && y < h {
		return bytelines[y][x], true
	}
	return 0, false
}

count :: proc(board: ^[][]u8, w: int, h: int, x: int, y: int) -> int {
	// Find "XMAS" in all directions, starting from x,y using the get function
    b, ok := get(board, w, h, x, y)
    if !ok {
    	return 0
    }
	if b != 'X' {
		return 0
	}
	return 1 // TODO: Count in all directions
}

main :: proc() {
	filename: string : "input"
	file_as_bytes_raw, ok := os.read_entire_file_from_filename(filename)
	if !ok {
		fmt.printfln("error: could not read %s", filename)
		return
	}

	board := bytes.split(bytes.trim_space(file_as_bytes_raw), []u8{'\n'})

	height := len(board)
	width := height > 0 ? len(board[0]) : 0

	//if len(board[height-1]) == 0 {
		//board = board[:height-1]
		//height -= 1
	//}

	fmt.printfln("w x h = %d x %d", width, height)

	//fmt.printfln("%c", get(&board, 0, 0))

    for y in 0..<height {
    	for x in 0..<width {
    		fmt.println(count(&board, width, height, x, y))
    	}
    	fmt.println()
    }
}
