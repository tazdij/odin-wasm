/*

! This file is generated by the shader compiler. Do not edit it manually. !

*/

package example

import gl  "../wasm/webgl"


Input_Locations_Rectangle :: struct {
	a_position: Attribute_vec2,
	a_color   : Attribute_vec4,
	u_matrix: Uniform_mat3,
}

input_locations_rectangle :: proc(s: ^Input_Locations_Rectangle, program: gl.Program) {
	s.a_position    = attribute_location_vec2(program, "a_position")
	s.a_color       = attribute_location_vec4(program, "a_color")
	s.u_matrix    = uniform_location_mat3(program, "u_matrix")
}

Uniform_Values_Rectangle :: struct {
	u_matrix: mat3,
}

uniforms_rectangle :: proc(loc: Input_Locations_Rectangle, v: Uniform_Values_Rectangle) {
	@static last: Uniform_Values_Rectangle
	if v.u_matrix    != last.u_matrix    do uniform_mat3(loc.u_matrix   , v.u_matrix   )
	last = v
}

Attribute_Values_Rectangle :: struct {
	a_position: vec2,
	a_color: vec4,
}

Input_Locations_Lighting :: struct {
	a_position: Attribute_vec3,
	a_normal  : Attribute_vec3,
	a_color   : Attribute_vec4,
	u_view       : Uniform_mat4,
	u_local      : Uniform_mat4,
	u_light_dir  : Uniform_vec3,
	u_light_color: Uniform_vec4,
}

input_locations_lighting :: proc(s: ^Input_Locations_Lighting, program: gl.Program) {
	s.a_position    = attribute_location_vec3(program, "a_position")
	s.a_normal      = attribute_location_vec3(program, "a_normal")
	s.a_color       = attribute_location_vec4(program, "a_color")
	s.u_view           = uniform_location_mat4(program, "u_view")
	s.u_local          = uniform_location_mat4(program, "u_local")
	s.u_light_dir      = uniform_location_vec3(program, "u_light_dir")
	s.u_light_color    = uniform_location_vec4(program, "u_light_color")
}

Uniform_Values_Lighting :: struct {
	u_view       : mat4,
	u_local      : mat4,
	u_light_dir  : vec3,
	u_light_color: vec4,
}

uniforms_lighting :: proc(loc: Input_Locations_Lighting, v: Uniform_Values_Lighting) {
	@static last: Uniform_Values_Lighting
	if v.u_view           != last.u_view           do uniform_mat4(loc.u_view          , v.u_view          )
	if v.u_local          != last.u_local          do uniform_mat4(loc.u_local         , v.u_local         )
	if v.u_light_dir      != last.u_light_dir      do uniform_vec3(loc.u_light_dir     , v.u_light_dir     )
	if v.u_light_color    != last.u_light_color    do uniform_vec4(loc.u_light_color   , v.u_light_color   )
	last = v
}

Attribute_Values_Lighting :: struct {
	a_position: vec3,
	a_normal: vec3,
	a_color: vec4,
}

Input_Locations_Candy :: struct {
	u_color_mult: Uniform_vec4,
	a_position: Attribute_vec3,
	a_color   : Attribute_vec4,
	u_view      : Uniform_mat4,
	u_local     : Uniform_mat4,
}

input_locations_candy :: proc(s: ^Input_Locations_Candy, program: gl.Program) {
	s.u_color_mult    = uniform_location_vec4(program, "u_color_mult")
	s.a_position    = attribute_location_vec3(program, "a_position")
	s.a_color       = attribute_location_vec4(program, "a_color")
	s.u_view          = uniform_location_mat4(program, "u_view")
	s.u_local         = uniform_location_mat4(program, "u_local")
}

Uniform_Values_Candy :: struct {
	u_color_mult: vec4,
	u_view      : mat4,
	u_local     : mat4,
}

uniforms_candy :: proc(loc: Input_Locations_Candy, v: Uniform_Values_Candy) {
	@static last: Uniform_Values_Candy
	if v.u_color_mult    != last.u_color_mult    do uniform_vec4(loc.u_color_mult   , v.u_color_mult   )
	if v.u_view          != last.u_view          do uniform_mat4(loc.u_view         , v.u_view         )
	if v.u_local         != last.u_local         do uniform_mat4(loc.u_local        , v.u_local        )
	last = v
}

Attribute_Values_Candy :: struct {
	a_position: vec3,
	a_color: vec4,
}

Input_Locations_Specular :: struct {
	u_light_color: Uniform_vec4,
	a_position: Attribute_vec3,
	a_normal  : Attribute_vec3,
	a_color   : Attribute_vec4,
	u_light_pos  : Uniform_vec3,
	u_eye_pos    : Uniform_vec3,
	u_view       : Uniform_mat4,
	u_local      : Uniform_mat4,
}

input_locations_specular :: proc(s: ^Input_Locations_Specular, program: gl.Program) {
	s.u_light_color    = uniform_location_vec4(program, "u_light_color")
	s.a_position    = attribute_location_vec3(program, "a_position")
	s.a_normal      = attribute_location_vec3(program, "a_normal")
	s.a_color       = attribute_location_vec4(program, "a_color")
	s.u_light_pos      = uniform_location_vec3(program, "u_light_pos")
	s.u_eye_pos        = uniform_location_vec3(program, "u_eye_pos")
	s.u_view           = uniform_location_mat4(program, "u_view")
	s.u_local          = uniform_location_mat4(program, "u_local")
}

Uniform_Values_Specular :: struct {
	u_light_color: vec4,
	u_light_pos  : vec3,
	u_eye_pos    : vec3,
	u_view       : mat4,
	u_local      : mat4,
}

uniforms_specular :: proc(loc: Input_Locations_Specular, v: Uniform_Values_Specular) {
	@static last: Uniform_Values_Specular
	if v.u_light_color    != last.u_light_color    do uniform_vec4(loc.u_light_color   , v.u_light_color   )
	if v.u_light_pos      != last.u_light_pos      do uniform_vec3(loc.u_light_pos     , v.u_light_pos     )
	if v.u_eye_pos        != last.u_eye_pos        do uniform_vec3(loc.u_eye_pos       , v.u_eye_pos       )
	if v.u_view           != last.u_view           do uniform_mat4(loc.u_view          , v.u_view          )
	if v.u_local          != last.u_local          do uniform_mat4(loc.u_local         , v.u_local         )
	last = v
}

Attribute_Values_Specular :: struct {
	a_position: vec3,
	a_normal: vec3,
	a_color: vec4,
}

Input_Locations_Boxes :: struct {
	a_position: Attribute_vec3,
	a_color   : Attribute_vec4,
	u_matrix: Uniform_mat4,
}

input_locations_boxes :: proc(s: ^Input_Locations_Boxes, program: gl.Program) {
	s.a_position    = attribute_location_vec3(program, "a_position")
	s.a_color       = attribute_location_vec4(program, "a_color")
	s.u_matrix    = uniform_location_mat4(program, "u_matrix")
}

Uniform_Values_Boxes :: struct {
	u_matrix: mat4,
}

uniforms_boxes :: proc(loc: Input_Locations_Boxes, v: Uniform_Values_Boxes) {
	@static last: Uniform_Values_Boxes
	if v.u_matrix    != last.u_matrix    do uniform_mat4(loc.u_matrix   , v.u_matrix   )
	last = v
}

Attribute_Values_Boxes :: struct {
	a_position: vec3,
	a_color: vec4,
}

Input_Locations_Spotlight :: struct {
	a_position: Attribute_vec3,
	a_normal  : Attribute_vec3,
	u_light_pos  : [2]Uniform_vec3,
	u_view       : Uniform_mat4,
	u_local      : Uniform_mat4,
	u_light_add  : [2]Uniform_float,
	u_light_color: [2]Uniform_vec4,
	u_light_dir  : [2]Uniform_vec3,
}

input_locations_spotlight :: proc(s: ^Input_Locations_Spotlight, program: gl.Program) {
	s.a_position    = attribute_location_vec3(program, "a_position")
	s.a_normal      = attribute_location_vec3(program, "a_normal")
	s.u_light_pos  [0] = uniform_location_vec3(program, "u_light_pos[0]")
	s.u_light_pos  [1] = uniform_location_vec3(program, "u_light_pos[1]")
	s.u_view           = uniform_location_mat4(program, "u_view")
	s.u_local          = uniform_location_mat4(program, "u_local")
	s.u_light_add  [0] = uniform_location_float(program, "u_light_add[0]")
	s.u_light_add  [1] = uniform_location_float(program, "u_light_add[1]")
	s.u_light_color[0] = uniform_location_vec4(program, "u_light_color[0]")
	s.u_light_color[1] = uniform_location_vec4(program, "u_light_color[1]")
	s.u_light_dir  [0] = uniform_location_vec3(program, "u_light_dir[0]")
	s.u_light_dir  [1] = uniform_location_vec3(program, "u_light_dir[1]")
}

Uniform_Values_Spotlight :: struct {
	u_light_pos  : [2]vec3,
	u_view       : mat4,
	u_local      : mat4,
	u_light_add  : [2]float,
	u_light_color: [2]vec4,
	u_light_dir  : [2]vec3,
}

uniforms_spotlight :: proc(loc: Input_Locations_Spotlight, v: Uniform_Values_Spotlight) {
	@static last: Uniform_Values_Spotlight
	if v.u_light_pos  [0] != last.u_light_pos  [0] do uniform_vec3(loc.u_light_pos  [0], v.u_light_pos  [0])
	if v.u_light_pos  [1] != last.u_light_pos  [1] do uniform_vec3(loc.u_light_pos  [1], v.u_light_pos  [1])
	if v.u_view           != last.u_view           do uniform_mat4(loc.u_view          , v.u_view          )
	if v.u_local          != last.u_local          do uniform_mat4(loc.u_local         , v.u_local         )
	if v.u_light_add  [0] != last.u_light_add  [0] do uniform_float(loc.u_light_add  [0], v.u_light_add  [0])
	if v.u_light_add  [1] != last.u_light_add  [1] do uniform_float(loc.u_light_add  [1], v.u_light_add  [1])
	if v.u_light_color[0] != last.u_light_color[0] do uniform_vec4(loc.u_light_color[0], v.u_light_color[0])
	if v.u_light_color[1] != last.u_light_color[1] do uniform_vec4(loc.u_light_color[1], v.u_light_color[1])
	if v.u_light_dir  [0] != last.u_light_dir  [0] do uniform_vec3(loc.u_light_dir  [0], v.u_light_dir  [0])
	if v.u_light_dir  [1] != last.u_light_dir  [1] do uniform_vec3(loc.u_light_dir  [1], v.u_light_dir  [1])
	last = v
}

Attribute_Values_Spotlight :: struct {
	a_position: vec3,
	a_normal: vec3,
}

Input_Locations_Pyramid :: struct {
	a_position: Attribute_vec3,
	a_color   : Attribute_vec4,
	u_matrix: Uniform_mat4,
}

input_locations_pyramid :: proc(s: ^Input_Locations_Pyramid, program: gl.Program) {
	s.a_position    = attribute_location_vec3(program, "a_position")
	s.a_color       = attribute_location_vec4(program, "a_color")
	s.u_matrix    = uniform_location_mat4(program, "u_matrix")
}

Uniform_Values_Pyramid :: struct {
	u_matrix: mat4,
}

uniforms_pyramid :: proc(loc: Input_Locations_Pyramid, v: Uniform_Values_Pyramid) {
	@static last: Uniform_Values_Pyramid
	if v.u_matrix    != last.u_matrix    do uniform_mat4(loc.u_matrix   , v.u_matrix   )
	last = v
}

Attribute_Values_Pyramid :: struct {
	a_position: vec3,
	a_color: vec4,
}

Input_Locations_Simple :: struct {
}

input_locations_simple :: proc(s: ^Input_Locations_Simple, program: gl.Program) {
}

Uniform_Values_Simple :: struct {
}

uniforms_simple :: proc(loc: Input_Locations_Simple, v: Uniform_Values_Simple) {
	@static last: Uniform_Values_Simple
	last = v
}

Attribute_Values_Simple :: struct {
}

