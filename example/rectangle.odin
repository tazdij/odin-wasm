package example

import gl "../wasm/webgl"


@(private="file") TRIANGLES :: 2
@(private="file") VERTICES  :: TRIANGLES * 3
@(private="file") BOX_W: f32 : 160
@(private="file") BOX_H: f32 : 100
@(private="file") box_size: [2]f32 = {BOX_W, BOX_H}

@(private="file") colors: [VERTICES*4]u8 = {
	60,  210, 0,   255, // G
	210, 210, 0,   255, // Y
	0,   80,  190, 255, // B

	230, 20,  0,   255, // R
	210, 210, 0,   255, // Y
	0,   80,  190, 255, // B
}
@(private="file") positions: [VERTICES*2]f32 = {
	0,     0,
	BOX_W, 0,
	0,     BOX_H,

	BOX_W, BOX_H,
	BOX_W, 0,
	0,     BOX_H,
}

@(private="file") state: struct {
	rotation:   f32,
	a_position: i32,
	a_color:    i32,
	u_matrix:   i32,
	vao:        VAO,
}

rectangle_start :: proc(program: gl.Program) {
	using state

	/*
	Position and color buffers are static,
	so we can bind them to the Vertex_Array_Object
	and reuse them in the draw call
	*/
	vao = gl.CreateVertexArray()
	gl.BindVertexArray(vao) // need to bind VAO before binding buffers

	a_position = gl.GetAttribLocation (program, "a_position")
	a_color    = gl.GetAttribLocation (program, "a_color")
	u_matrix   = gl.GetUniformLocation(program, "u_matrix")

	gl.EnableVertexAttribArray(a_position)
	gl.EnableVertexAttribArray(a_color)

	positions_buffer := gl.CreateBuffer()
	colors_buffer    := gl.CreateBuffer()

	gl.BindBuffer(gl.ARRAY_BUFFER, positions_buffer)
	gl.BufferDataSlice(gl.ARRAY_BUFFER, positions[:], gl.STATIC_DRAW)
	gl.VertexAttribPointer(a_position, 2, gl.FLOAT, false, 0, 0)

	gl.BindBuffer(gl.ARRAY_BUFFER, colors_buffer)
	gl.BufferDataSlice(gl.ARRAY_BUFFER, colors[:], gl.STATIC_DRAW)
	gl.VertexAttribPointer(a_color, 4, gl.UNSIGNED_BYTE, true, 0, 0)
}

rectangle_frame :: proc(delta: f32) {
	using state

	gl.BindVertexArray(vao)
	
	gl.Viewport(0, 0, canvas_res.x, canvas_res.y)
	gl.ClearColor(0, 0.01, 0.02, 0)
	gl.Clear(gl.COLOR_BUFFER_BIT)

	rotation += 0.01 * delta * (window_size.x / 2 - mouse_pos.x) / window_size.x
	mat :=
		mat3_projection(canvas_size) *
		mat3_translate(mouse_pos - canvas_pos) *
		mat3_scale(scale) *
		mat3_rotate(rotation) *
		mat3_translate(-box_size / 2)

	gl.UniformMatrix3fv(u_matrix, mat)

	gl.DrawArrays(gl.TRIANGLES, 0, VERTICES)
}