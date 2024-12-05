package main

import "core:bytes"
import "core:fmt"
import "core:os"

get :: proc(bytelines: ^[][]u8, w: int, h: int, x: int, y: int) -> (u8, bool) {
	if x >= 0 && x < w && y >= 0 && y < h {
		return bytelines[y][x], true
	}
	return 0, false
}

hasword :: proc(
	board: ^[][]u8,
	w: int,
	h: int,
	startx: int,
	starty: int,
	dx: int,
	dy: int,
	word: string,
) -> bool {
	x := startx
	y := starty
	index := 0
	lastIndex := len(word) - 1
	for {
		b, ok := get(board, w, h, x, y)
		if !ok {
			break
		}
		if b != word[index] {
			break
		}
		if index == lastIndex {
			return true // found XMAS!
		}
		index += 1 // next letter
		x += dx // next x position
		y += dy // next y position
	}
	return false
}

count :: proc(board: ^[][]u8, w: int, h: int, x: int, y: int, word: string) -> int {
	// Find "XMAS" in all directions, starting from x,y using the get function
	b, ok := get(board, w, h, x, y)
	if !ok {
		return 0
	}
	if b != 'X' {
		return 0
	}
	counter := 0

	// count words for all diagonals
	counter += hasword(board, w, h, x, y, 1, 1, word) ? 1 : 0
	counter += hasword(board, w, h, x, y, -1, -1, word) ? 1 : 0
	counter += hasword(board, w, h, x, y, 1, -1, word) ? 1 : 0
	counter += hasword(board, w, h, x, y, -1, 1, word) ? 1 : 0

	// count words for the horizontal and vertical
	counter += hasword(board, w, h, x, y, 0, 1, word) ? 1 : 0
	counter += hasword(board, w, h, x, y, 0, -1, word) ? 1 : 0
	counter += hasword(board, w, h, x, y, 1, 0, word) ? 1 : 0
	counter += hasword(board, w, h, x, y, -1, 0, word) ? 1 : 0

	return counter
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

	fmt.printfln("w x h = %d x %d", width, height)

	word: string : "XMAS"

	counter := 0

	for y in 0 ..< height {
		for x in 0 ..< width {
			counter += count(&board, width, height, x, y, word)
		}
	}

	fmt.printfln("total count: %d", counter)
}
