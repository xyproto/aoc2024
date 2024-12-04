package main

import "core:bytes"
import "core:fmt"
import "core:os"
import "core:strconv"

valid_mul_byte :: proc(b: u8) -> bool {
	switch b {
	case '0' ..= '9', 'm', 'u', 'l', '(', ')', ',':
		return true
	}
	return false
}

valid_mul_do_dont_byte :: proc(b: u8) -> bool {
	switch b {
	case '0' ..= '9', 'm', 'u', 'l', '(', ')', ',', 'd', 'o', 'n', 't', '\'':
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
	enabled := true
	line_counter: u128

	file_as_bytes := only_keep(file_as_bytes_raw, valid_mul_do_dont_byte)
	//file_as_bytes := replace_invalid_with(file_as_bytes_raw, valid_mul_do_dont_byte, 'x')

	for byte_line, line_index in bytes.split(file_as_bytes, []u8{'m', 'u', 'l', '('}) {
		s_bytes, rightp, tail_bytes := bytes.partition(byte_line, []u8{')'})

		if len(rightp) == 0 || len(rightp) > 0 && rightp[0] != ')' { 	// if the line contains no ) after mul(, then this line does not contain mul(...) nor do() nor don't()
			continue
		}

		if len(s_bytes) < 3 { 	// not enough bytes for at least one digit, a comma and one digit, or "do(" or "don't("
			continue
		}

		result: u128
		ok: bool

		if enabled {
			result, ok = multiply_numbers_if_possible(s_bytes)
			if ok {
				sum += result
			}
		}

		if len(tail_bytes) == 0 { 	// no tail that can contain "do()" or "don't()"
			continue
		}

		pre_enabled := enabled

		// not efficient, but hey
		for i in 0 ..< len(tail_bytes) {
			if bytes.has_prefix(tail_bytes[i:], []u8{'d', 'o', '(', ')'}) {
				enabled = true
			} else if bytes.has_prefix(tail_bytes[i:], []u8{'d', 'o', 'n', '\'', 't', '(', ')'}) {
				enabled = false
			}
		}

		fmt.printfln(
			"index %d: %s, got: %s, result: %d, tail: %s, enabled: %v => %v",
			line_index,
			byte_line,
			s_bytes,
			result,
			tail_bytes,
			pre_enabled,
			enabled,
		)
	}

	fmt.printfln("got sum: %d", sum)
}
