package main

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

main :: proc() {
	filename: string : "input"
	file_as_bytes_raw, ok := os.read_entire_file_from_filename(filename)
	if !ok {
		fmt.printfln("error: could not read %s", filename)
		return
	}

	digit_a_builder: [dynamic]u8
	defer delete(digit_a_builder)

	digit_b_builder: [dynamic]u8
	defer delete(digit_b_builder)

	mightbemul := 0
	mightbedo := 0
	mightbedont := 0

	enabled := true

	sum: u128

	for b, i in file_as_bytes_raw {
		switch b {
		case 'd':
			mightbedo = 1
			mightbedont = 1
			mightbemul = 0
		case 'o':
			if mightbedo == 1 {
				mightbedo = 2
			}
			if mightbedont == 1 {
				mightbedont = 2
			}
			mightbemul = 0
		case 'n':
			mightbedo = 0
			if mightbedont == 2 {
				mightbedont = 3
			} else {
				mightbedont = 0
			}
			mightbemul = 0
		case '\'':
			mightbedo = 0
			if mightbedont == 3 {
				mightbedont = 4
			} else {
				mightbedont = 0
			}
			mightbemul = 0
		case 't':
			mightbemul = 0
			mightbedo = 0
			if mightbedont == 4 {
				mightbedont = 5
			} else {
				mightbedont = 0
			}
		case 'm':
			mightbemul = 1
			mightbedo = 0
			mightbedont = 0
		case 'u':
			if mightbemul == 1 {
				mightbemul = 2
			}
			mightbedo = 0
			mightbedont = 0
		case 'l':
			if mightbemul == 2 {
				mightbemul = 3
			}
			mightbedo = 0
			mightbedont = 0
		case '0' ..= '9':
			if mightbemul == 4 || mightbemul == 5 {
				mightbemul = 5
				append(&digit_a_builder, b)
				if len(digit_a_builder) > 3 {
					mightbemul = 0
				}
			} else if mightbemul == 6 {
				append(&digit_b_builder, b)
				if len(digit_b_builder) > 3 {
					mightbemul = 0
				}
			} else {
				mightbemul = 0
				mightbedo = 0
				mightbedont = 0
			}
		case ',':
			if mightbemul == 5 {
				mightbemul = 6
			} else {
				mightbemul = 0
			}
			mightbedo = 0
			mightbedont = 0
		case '(':
			if mightbemul == 3 {
				mightbemul = 4
			} else {
				mightbemul = 0
			}
			if mightbedo == 2 {
				mightbedo = 3
			} else {
				mightbedo = 0
			}
			if mightbedont == 5 { 	// including '
				mightbedont = 6
			} else {
				mightbedont = 0
			}
		case ')':
			if mightbedo == 3 {
				fmt.println("ON")
				enabled = true
			} else if mightbedont == 6 {
				fmt.println("OFF")
				enabled = false
			} else if mightbemul == 6 && enabled {
				a_str := string(undynamic(digit_a_builder))
				b_str := string(undynamic(digit_b_builder))
				a, ok1 := strconv.parse_u128_maybe_prefixed(a_str)
				b, ok2 := strconv.parse_u128_maybe_prefixed(b_str)
				if ok1 && ok2 {
					fmt.printfln("%d x %d, enabled: %v", a, b, enabled)
					sum += a * b
				}
			}
			fallthrough // reset state
		case:
			// default
			mightbemul = 0
			mightbedo = 0
			mightbedont = 0
			clear(&digit_a_builder)
			clear(&digit_b_builder)
		}
		fmt.printfln(
			"%d: %c, do: %d, don't: %d, mul: %d",
			i,
			b,
			mightbedo,
			mightbedont,
			mightbemul,
		)
	}
	fmt.printfln("sum: %v", sum)
}
