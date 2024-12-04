package main

import "core:bytes"
import "core:fmt"
import "core:os"
import "core:strconv"

valid_mul_byte :: proc(b: u8) -> bool {
	switch b {
	case '0'..='9', 'm', 'u', 'l', '(', ')', ',':
		return true
	}
	return false
}

valid_mul_do_dont_byte :: proc(b: u8) -> bool {
	switch b {
	case '0'..='9', 'm', 'u', 'l', '(', ')', ',', 'd', 'o', 'n', 't', '\'':
		return true
	}
	return false
}

// only_keep will return a new byte slice where every byte is valid according to the valid_func function.
// invalid bytes are skipped.
only_keep :: proc(xs: []u8, valid_func: proc(_: byte) -> bool) -> []u8 {
	collector: [dynamic]u8
	defer delete(collector)
	for b in xs {
		if valid_func(b) {
			append(&collector, b)
		}
	}
	result := make([]u8, len(collector))
	for r, i in collector {
		result[i] = r
	}
	return result
}

// replace_invalid_with replaces all bytes in the given byte slice with the given relpacement byte,
// if the given valid_func considers a bytes to be invalid. If the replacement byte is ' ', then it will be skipped.
replace_invalid_with :: proc(
	xs: []u8,
	valid_func: proc(_: byte) -> bool,
	replacement: u8,
) -> []u8 {
	collector: [dynamic]u8
	defer delete(collector)
	for b in xs {
		if valid_func(b) {
			append(&collector, b)
		} else if replacement != ' ' {
			append(&collector, replacement)
		}
	}
	result := make([]u8, len(collector))
	for r, i in collector {
		result[i] = r
	}
	return result
}

extract_numbers :: proc(xs: []u8) -> (u128, u128, bool) {
	first, _, second := bytes.partition(xs, []u8{','})
	if len(first) == 0 || len(first) > 3 {
		return 0, 0, false
	}
	if len(second) == 0 || len(second) > 3 {
		return 0, 0, false
	}
	a, ok1 := strconv.parse_u128_maybe_prefixed(string(first))
	b, ok2 := strconv.parse_u128_maybe_prefixed(string(second))
	return a, b, ok1 && ok2
}

// returns the result of the multiplication, and false if something is invalid
multiply_numbers_if_possible :: proc(xs: []u8) -> (u128, bool) {
	has_comma := false
	for b in xs {
		if !valid_mul_byte(b) {
			return 0, false // contains an invalid rune, this is rare
		}
		if b == ',' {
			has_comma = true
		}
	}
	if !has_comma { 	// no comma
		return 0, false
	}
	a, b, valid := extract_numbers(xs)
	if valid {
		return a * b, true
	}
	return 0, false
}

main :: proc() {
	filename: string : "input"

	file_as_bytes_raw, ok := os.read_entire_file_from_filename(filename)
	if !ok {
		fmt.printfln("error: could not read %s", filename)
		return
	}

	sum: u128
	line_counter: u128

	digit_a_builder: [dynamic]u8
	defer delete(digit_a_builder)

	digit_b_builder: [dynamic]u8
	defer delete(digit_b_builder)

	mightbemul := 0
	mightbedo := 0
	mightbedont := 0

	enabled := true

	for b in file_as_bytes_raw {
		switch b {
			case 'd':
				mightbedo = 1
				mightbedont = 1
			case 'o':
				if mightbedo == 1 {
					mightbedo = 2
				}
				if mightbedont == 1 {
					mightbedont = 2
				}
			case 'n':
				mightbemul = 0
				mightbedo = 0
				if mightbedont == 2 {
					mightbedont = 3
				}
			case '\'':
				if mightbedont == 3 {
					mightbedont = 4
				}
			case 't':
				mightbemul = 0
				mightbedo = 0
				if mightbedont == 4 {
					mightbedont = 5
				}
			case 'm':
				mightbemul = 1
			case 'u':
				if mightbemul == 1 {
					mightbemul = 2
				}
			case 'l':
				if mightbemul == 2 {
					mightbemul = 3
				}
			case '0'..='9':
				if mightbemul == 4 {
					append(&digit_a_builder, b)
					if len(digit_a_builder) > 3 {
						mightbemul = 0
					}
				} else if mightbemul == 6 {
					append(&digit_b_builder, b)
					if len(digit_b_builder) > 3 {
						mightbemul = 0
					}
				}
			case ',':
				if mightbemul == 4 {
					mightbemul = 5
				}
			case '(':
				if mightbemul == 3 {
					mightbemul = 4
				}
				if mightbedo == 2 {
					mightbedo = 3
				}
				if mightbedont == 5 {
					mightbedont = 6
				}
			case ')':
				if mightbedo == 3 {
					fmt.println("ON")
					enabled = true
				} else if mightbedont == 6 {
					fmt.println("OFF")
					enabled = false
				} else if mightbemul == 6 {
					fmt.printfln("%s x %s", digit_a_builder, digit_b_builder)
					// DO STUFF HERE
				}
				fallthrough // reset state
		    case: // default
		   	mightbemul = 0
		   	mightbedo = 0
		   	mightbedont = 0
		   	clear(&digit_a_builder)
		   	clear(&digit_b_builder)
		}
	}
}
