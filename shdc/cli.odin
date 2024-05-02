package shdc

import "core:fmt"
import str "core:strings"
import "core:os"

write :: str.write_string

write_pad :: proc(b: ^str.Builder, pad: int) {
	for _ in 0..<pad {
		write(b, " ")
	}
}

write_pad_str :: proc(b: ^str.Builder, s: string, pad: int) {
	write(b, s)
	write_pad(b, max(pad - len(s), 0))
}

write_arr_brackets :: proc(b: ^str.Builder, len: int) {
	write(b, "[")
	str.write_int(b, len)
	write(b, "]")
}

output_header: string : `/*

! This file is generated by the shader compiler. Do not edit it manually. !

*/

package example

import gl  "../wasm/webgl"


`

main :: proc() {
	context.allocator = context.temp_allocator

	b := str.builder_make_len_cap(0, 10000)
	write(&b, output_header)

	dir_handle, open_err := os.open("example")
	if open_err != 0 {
		panic("failed to open directory")
	}

	file_infos, read_err := os.read_dir(dir_handle, -1)
	if read_err != 0 {
		panic("failed to read directory")
	}

	Shader_Group :: struct {
		name   : string,
		inputs : [dynamic]Shader_Input,
	}

	inputs_all := make([]Shader_Group, len(file_infos))
	inputs_all_len := 0


	for fi in file_infos {
		if fi.is_dir do continue

		ext_idx := len(fi.name)-5
		if ext_idx <= 0 do continue

		file_name := fi.name[:ext_idx]
		
		shader_kind: Shader_Kind
		switch fi.name[ext_idx:] {
		case ".vert": shader_kind = .Vert
		case ".frag": shader_kind = .Frag
		case: continue 
		}

		inputs: ^[dynamic]Shader_Input
		search: {
			for &item in inputs_all[:inputs_all_len] {
				if item.name == file_name {
					inputs = &item.inputs
					break search
				}
			}
			
			inputs_all[inputs_all_len] = {
				name=file_name,
				inputs=make([dynamic]Shader_Input, 0, 12),
			}
			inputs = &inputs_all[inputs_all_len].inputs
			inputs_all_len += 1
		}

		file_buf := os.read_entire_file(fi.fullpath) or_else fmt.panicf("failed to read file: %s\n", fi.fullpath)
		err := shader_inputs_append(inputs, string(file_buf), shader_kind)
		if err != nil {
			fmt.panicf("error: %v\n", err)
		}
	}


	for &item in inputs_all[:inputs_all_len] {
		file_name_snake := str.to_snake_case(item.name); defer delete(file_name_snake)
		file_name_ada   := str.to_ada_case  (item.name); defer delete(file_name_ada)

		/* Max input names for aligning */
		max_len: [Shader_Input_Kind]int
		for input in item.inputs {
			max_len[input.kind] = max(max_len[input.kind], len(input.name))
		}

		/*
		Locations Type
		*/
		write(&b, "Input_Locations_")
		write(&b, file_name_ada)
		write(&b, " :: struct {\n")
		
		for input in item.inputs {
			write(&b, "\t")
			write_pad_str(&b, input.name, max_len[input.kind])
			write(&b, ": ")
			if input.len > 1 {
				write_arr_brackets(&b, input.len)
			}
			write(&b, input.kind == .Uniform ? "Uniform_" : "Attribute_")
			write(&b, input.type)
			write(&b, ",\n")
		}

		write(&b, "}\n\n")

		/*
		Locations Proc
		*/
		write(&b, "input_locations_")
		write(&b, file_name_snake)
		write(&b, " :: proc(s: ^Input_Locations_")
		write(&b, file_name_ada)
		write(&b, ", program: gl.Program) {\n")

		for input in item.inputs {
			if input.len == 0 {
				write(&b, "\ts.")
				write_pad_str(&b, input.name, max_len[input.kind]+3)
				write(&b, " = ")
				write(&b, input.kind == .Uniform ? "uniform_location_" : "attribute_location_")
				write(&b, input.type)
				write(&b, "(program, \"")
				write(&b, input.name)
				write(&b, "\")\n")
			} else {
				for i in 0..<input.len {
					write(&b, "\ts.")
					write_pad_str(&b, input.name, max_len[input.kind])
					write_arr_brackets(&b, i)
					write(&b, " = ")
					write(&b, input.kind == .Uniform ? "uniform_location_" : "attribute_location_")
					write(&b, input.type)
					write(&b, "(program, \"")
					write(&b, input.name)
					write_arr_brackets(&b, i)
					write(&b, "\")\n")
				}
			}
		}
		write(&b, "}\n\n")

		/*
		Uniforms Type
		*/
		write(&b, "Uniform_Values_")
		write(&b, file_name_ada)
		write(&b, " :: struct {\n")

		for input in item.inputs {
			if input.kind != .Uniform do continue

			write(&b, "\t")
			write_pad_str(&b, input.name, max_len[.Uniform])
			write(&b, ": ")

			if input.len > 1 {
				write_arr_brackets(&b, input.len)
			}

			write(&b, input.type)
			write(&b, ",\n")
		}
		write(&b, "}\n\n")

		/*
		Uniforms Proc
		*/
		write(&b, "uniforms_")
		write(&b, file_name_snake)
		write(&b, " :: proc(loc: Input_Locations_")
		write(&b, file_name_ada)
		write(&b, ", v: Uniform_Values_")
		write(&b, file_name_ada)
		write(&b, ") {\n")
		write(&b, "\t@static last: Uniform_Values_")
		write(&b, file_name_ada)
		write(&b, "\n")

		for input in item.inputs {
			if input.kind != .Uniform do continue

			for i in 0..<max(input.len, 1) {
				write(&b, "\tif v.")
				if input.len > 1 {
					write_pad_str(&b, input.name, max_len[.Uniform])
					write_arr_brackets(&b, i)
				} else {
					write_pad_str(&b, input.name, max_len[.Uniform]+3)
				}
				write(&b, " != last.")
				if input.len > 1 {
					write_pad_str(&b, input.name, max_len[.Uniform])
					write_arr_brackets(&b, i)
				} else {
					write_pad_str(&b, input.name, max_len[.Uniform]+3)
				}
				write(&b, " do uniform_")
				write(&b, input.type)
				write(&b, "(loc.")
				if input.len > 1 {
					write_pad_str(&b, input.name, max_len[.Uniform])
					write_arr_brackets(&b, i)
				} else {
					write_pad_str(&b, input.name, max_len[.Uniform]+3)
				}
				write(&b, ", v.")
				if input.len > 1 {
					write_pad_str(&b, input.name, max_len[.Uniform])
					write_arr_brackets(&b, i)
				} else {
					write_pad_str(&b, input.name, max_len[.Uniform]+3)
				}
				write(&b, ")\n")
			}
		}

		write(&b, "\tlast = v\n")
		write(&b, "}\n\n")

		/*
		Attributes Type
		*/
		write(&b, "Attribute_Values_")
		write(&b, file_name_ada)
		write(&b, " :: struct {\n")

		for input in item.inputs {
			if input.kind != .Attribute do continue

			write(&b, "\t")
			write(&b, input.name)
			write(&b, ": ")
			write(&b, input.type)
			write(&b, ",\n")
		}
		write(&b, "}\n\n")
	}
	

	ok := os.write_entire_file("example/shaders_generated.odin", b.buf[:])
	if !ok {
		fmt.printf("failed to write file\n")
	}

	os.exit(0)
}
