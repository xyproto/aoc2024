package main

import "core:fmt"
import "core:os"
import "core:strings"

Guard :: struct {
	x: int, // position
	y: int, // position
	dx: int, // direction
	dy: int, // direction
}

turn90 :: proc(g: ^Guard) {
	if g.dx == -1 && g.dy == 0 { // pointing left
		// point up
		g.dx = 0
		g.dy = -1
	} else if g.dx == 0 && g.dy == -1 { // pointing up
		// point right
		g.dx = 1
		g.dy = 0
	} else if g.dx == 1 && g.dy == 0 { // pointing right {
		// point down
		g.dx = 0
		g.dy = 1
	} else if g.dx == 0 && g.dy == 1 { // pointing down {
		// point left
		g.dx = -1
		g.dy = 0
	}
}

Blocker :: struct {
	x: int, // position
	y: int, // position
}

main :: proc() {
	filename: string : "input"
	data, ok := os.read_entire_file(filename)
	if !ok {
		fmt.printfln("could not read file: %s", filename)
		return
	}
	defer delete(data)
	dataString := string(data)
	y := 0
	for line in strings.split_lines_iterator(&dataString) {
		for r, x in line {
			switch r {
				case '#':
					b := Blocker{x, y}
					fmt.printfln("%v", b)
				case '^':
					g := Guard{x, y, 0, -1}
					fmt.printfln("%v", g)
				case 'v':
					g := Guard{x, y, 0, 1}
					fmt.printfln("%v", g)
				case '<':
					g := Guard{x, y, -1, 0}
					fmt.printfln("%v", g)
				case '>':
					g := Guard{x, y, 1, 0}
					fmt.printfln("%v", g)
			}
		}
		y += 1
	}
}
