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

has :: proc(bytelines: ^[][]u8, w: int, h: int, x: int, y: int, letter: u8) -> bool {
	if x >= 0 && x < w && y >= 0 && y < h {
		return bytelines[y][x] == letter
	}
	return false
}

hasword :: proc(board: ^[][]u8, w: int, h: int, startx: int, starty: int, dx: int, dy: int, word: string) -> bool {
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

hasx :: proc(board: ^[][]u8, w: int, h: int, x: int, y: int, word: string) -> bool {
	if len(word) % 2 == 0 {
		fmt.println("will only search for an X of odd words!")
		return false
	}
	centerIndex := (len(word) - 1) / 2

	if !has(board, w, h, x, y, word[centerIndex]) {
		return false
	}

	fmt.printfln("found letter %c at %d, %d", word[centerIndex], x, y)

	downright1 := true
	downright2 := true

	// from upper left to lower right
	for i := -centerIndex; i <= centerIndex; i += 1 { // -1, 0, 1
		if i == 0 {
			continue
		}
		fmt.printf("a checking %d,%d for letter %c: ", x+i, y+i, word[centerIndex+i])
		if !has(board, w, h, x + i, y + i, word[centerIndex+i]) {
			fmt.println("nope")
			downright1 = false
			if !downright1 && !downright2 {
				return false
			}
		} else {
			fmt.println("found")
		}
		fmt.printf("a checking %d,%d for letter %c: ", x+i, y+i, word[centerIndex-i])
		if !has(board, w, h, x + i, y + i, word[centerIndex-i]) {
			fmt.println("nope")
			downright2 = false
			if !downright1 && !downright2 {
				return false
			}
		} else {
			fmt.println("found")
		}
	}

	upright1 := true
	upright2 := true

	// from lower left to upper right
	for i := -centerIndex; i <= centerIndex; i += 1 { // -1, 0, 1
		if i == 0 {
			continue
		}
		fmt.printf("b checking %d,%d for letter %c: ", x+i, y-i, word[centerIndex+i])
		if !has(board, w, h, x + i, y - i, word[centerIndex+i]) {
			fmt.println("nope")
			upright1 = false
			if !upright1 && !upright2 {
				return false
			}
		} else {
			fmt.println("found")
		}
		fmt.printf("b checking %d,%d for letter %c: ", x+i, y-i, word[centerIndex-i])
		if !has(board, w, h, x + i, y - i, word[centerIndex-i]) {
			fmt.println("nope")
			upright2 = false
			if !upright1 && !upright2 {
				return false
			}
		} else {
			fmt.println("found")
		}
	}

	// from lower left to upper right, reverse word
	for i := -centerIndex; i <= centerIndex; i += 1 { // -1, 0, 1
		if i == 0 {
			continue
		}
	}

	if !upright1 && !upright2 {
		return false
	}

	fmt.printfln("found one X with center at %d,%d!", x, y)

	return true // Found one!
}

main :: proc() {
	filename: string : "input"
	file_as_bytes, ok := os.read_entire_file_from_filename(filename)
	if !ok {
		fmt.printfln("error: could not read %s", filename)
		return
	}

	board := bytes.split(bytes.trim_space(file_as_bytes), []u8{'\n'})

	height := len(board)
	width := height > 0 ? len(board[0]) : 0

	fmt.printfln("w x h = %d x %d", width, height)

	word: string : "MAS"

	counter := 0

	for y in 0 ..< height {
		for x in 0 ..< width {
			counter += hasx(&board, width, height, x, y, word) ? 1 : 0
		}
	}

	fmt.printfln("total count: %d", counter)
}
