package example


WHITE : RGBA : {255, 255, 255, 255}
GREEN : RGBA : {60, 210, 0, 255}
YELLOW: RGBA : {210, 200, 0, 255}
BLUE  : RGBA : {0, 80, 190, 255}
CYAN  : RGBA : {0, 210, 210, 255}
RED   : RGBA : {230, 20, 0, 255}
ORANGE: RGBA : {250, 150, 50, 255}
PURPLE: RGBA : {160, 100, 200, 255}
PURPLE_DARK: RGBA : {80, 30, 30, 255}
BLACK : RGBA : {0, 0, 0, 255}


CUBE_TRIANGLES :: 6 * 2
CUBE_VERTICES  :: CUBE_TRIANGLES * 3

CUBE_POSITIONS: [CUBE_VERTICES]Vec : {
	{0, 0, 0}, // 0
	{1, 0, 0},
	{0, 0, 1},

	{0, 0, 1}, // 1
	{1, 0, 0},
	{1, 0, 1},

	{0, 0, 1}, // 2
	{1, 0, 1},
	{0, 1, 1},

	{0, 1, 1}, // 3
	{1, 0, 1},
	{1, 1, 1},

	{0, 0, 0}, // 4
	{0, 0, 1},
	{0, 1, 1},

	{0, 0, 0}, // 5
	{0, 1, 1},
	{0, 1, 0},

	{1, 0, 0}, // 6
	{1, 1, 1},
	{1, 0, 1},

	{1, 0, 0}, // 7
	{1, 1, 0},
	{1, 1, 1},

	{0, 0, 0}, // 8
	{1, 1, 0},
	{1, 0, 0},

	{0, 0, 0}, // 9
	{0, 1, 0},
	{1, 1, 0},

	{0, 1, 0}, // 10
	{0, 1, 1},
	{1, 1, 1},
	
	{0, 1, 0}, // 11
	{1, 1, 1},
	{1, 1, 0},
}

CUBE_NORMALS: [CUBE_VERTICES]Vec : {
	{0, -1, 0}, // 0
	{0, -1, 0},
	{0, -1, 0},
	{0, -1, 0}, // 1
	{0, -1, 0},
	{0, -1, 0},
	
	{0, 0, 1}, // 2
	{0, 0, 1},
	{0, 0, 1},
	{0, 0, 1}, // 3
	{0, 0, 1},
	{0, 0, 1},
	
	{-1, 0, 0}, // 4
	{-1, 0, 0},
	{-1, 0, 0},
	{-1, 0, 0}, // 5
	{-1, 0, 0},
	{-1, 0, 0},
	
	{1, 0, 0}, // 6
	{1, 0, 0},
	{1, 0, 0},
	{1, 0, 0}, // 7
	{1, 0, 0},
	{1, 0, 0},
	
	{0, 0, -1}, // 8
	{0, 0, -1},
	{0, 0, -1},
	{0, 0, -1}, // 9
	{0, 0, -1},
	{0, 0, -1},
	
	{0, 1, 0}, // 10
	{0, 1, 0},
	{0, 1, 0},
	{0, 1, 0}, // 11
	{0, 1, 0},
	{0, 1, 0},
}

get_cube_positions :: proc(pos: Vec = 0, h: f32 = 1) -> [CUBE_VERTICES]Vec {
	positions := CUBE_POSITIONS
	for &vec in positions {
		vec = pos + (vec - {0.5, 0.5, 0.5}) * h
	}
	return positions
}


PYRAMID_TRIANGLES :: 6
PYRAMID_VERTICES  :: PYRAMID_TRIANGLES * 3

get_pyramid_positions :: proc(pos: Vec = 0, h: f32 = 1) -> [PYRAMID_VERTICES]Vec {
	x := pos.x - h/2
	y := pos.y - h/2
	z := pos.z - h/2

	return {
		{x, y, z},   {x+h, y, z}, {x,   y, z+h},
		{x, y, z+h}, {x+h, y, z}, {x+h, y, z+h},

		{x,   y, z},   {x+h/2, y+h, z+h/2}, {x+h, y, z},
		{x+h, y, z},   {x+h/2, y+h, z+h/2}, {x+h, y, z+h},
		{x+h, y, z+h}, {x+h/2, y+h, z+h/2}, {x,   y, z+h},
		{x,   y, z+h}, {x+h/2, y+h, z+h/2}, {x,   y, z},
	}
}

get_sphere_base_triangle :: proc(positions, normals: []Vec, radius: f32, segments: int) {
	// TODO: merge top and bottom segment triangles
	si := 0 // segment index
	for vi in 0..<segments { // vertical
		va0   := PI * (f32(vi)  ) / f32(segments)
		va1   := PI * (f32(vi)+1) / f32(segments)
		hmove := 0.5 * f32(vi%2)

		for hi in 0..<segments { // horizontal
			ha0 := 2*PI * (f32(hi)-0.5 + hmove) / f32(segments)
			ha1 := 2*PI * (f32(hi)     + hmove) / f32(segments)
			ha2 := 2*PI * (f32(hi)+0.5 + hmove) / f32(segments)
			ha3 := 2*PI * (f32(hi)+1   + hmove) / f32(segments)

			// Vertices
			v0 := Vec{cos(ha0)*sin(va1), cos(va1), sin(ha0)*sin(va1)}
			v1 := Vec{cos(ha1)*sin(va0), cos(va0), sin(ha1)*sin(va0)}
			v2 := Vec{cos(ha2)*sin(va1), cos(va1), sin(ha2)*sin(va1)}
			v3 := Vec{cos(ha3)*sin(va0), cos(va0), sin(ha3)*sin(va0)}

			// Normals
			n0 := normalize(v0)
			n1 := normalize(v1)
			n2 := normalize(v2)
			n3 := normalize(v3)

			// Triangle 1
			positions[si+0] = v0 * radius
			positions[si+1] = v1 * radius
			positions[si+2] = v2 * radius

			normals  [si+0] = n0
			normals  [si+1] = n1
			normals  [si+2] = n2

			// Triangle 2
			positions[si+3] = v1 * radius
			positions[si+4] = v3 * radius
			positions[si+5] = v2 * radius

			normals  [si+3] = n1
			normals  [si+4] = n3
			normals  [si+5] = n2

			si += 6
		}
	}
}

get_sphere_base_rectangle :: proc(positions, normals: []Vec, radius: f32, segments: int) {
	// TODO: merge top and bottom segment triangles
	si := 0 // segment index
	for vi in 0..<segments { // vertical
		for hi in 0..<segments { // horizontal
			va0 :=   PI * f32(vi+0) / f32(segments)
			va1 :=   PI * f32(vi+1) / f32(segments)
			ha0 := 2*PI * f32(hi+0) / f32(segments)
			ha1 := 2*PI * f32(hi+1) / f32(segments)
			
			// Vertices
			v0 := Vec{cos(ha0)*sin(va1), cos(va1), sin(ha0)*sin(va1)}
			v1 := Vec{cos(ha0)*sin(va0), cos(va0), sin(ha0)*sin(va0)}
			v2 := Vec{cos(ha1)*sin(va1), cos(va1), sin(ha1)*sin(va1)}
			v3 := Vec{cos(ha1)*sin(va0), cos(va0), sin(ha1)*sin(va0)}

			// Normals
			n0 := normalize(v0)
			n1 := normalize(v1)
			n2 := normalize(v2)
			n3 := normalize(v3)

			// Triangle 1
			positions[si+0] = v0 * radius
			positions[si+1] = v1 * radius
			positions[si+2] = v2 * radius

			normals  [si+0] = n0
			normals  [si+1] = n1
			normals  [si+2] = n2

			// Triangle 2
			positions[si+3] = v1 * radius
			positions[si+4] = v3 * radius
			positions[si+5] = v2 * radius

			normals  [si+3] = n1
			normals  [si+4] = n3
			normals  [si+5] = n2

			si += 6
		}
	}
}

JOINT_TRIANGLES :: 8
JOINT_VERTICES  :: 3 * JOINT_TRIANGLES

get_joint :: proc(from, to: Vec, w: f32) -> [JOINT_VERTICES]Vec {
	
	mid := from*(1.0/3.0) + to*(2.0/3.0)
	
	from, to := from, to
	
	normal := normalize(to - from)

	mat_x: Mat4
	mat_z: Mat4

	if normal.x > 0.5 || normal.x < -0.5 {
		mat_x = mat4_rotate_y(PI/2)
		mat_z = mat4_rotate_z(PI/2)
	} else {
		mat_x = mat4_rotate_x(PI/2)
		if normal.z > 0.5 || normal.z < -0.5 {
			mat_z = mat4_rotate_y(PI/2)
		} else {
			mat_z = mat4_rotate_z(PI/2)
			if normal.y > 0.5 || normal.y < -0.5 {
				mat_z = mat4_rotate_z(PI/2)
			} else {
				mat_z = mat4_rotate_x(PI/2)
			}
		}
	}

	normal_x := vec3_transform(normal, mat_x)
	normal_z := vec3_transform(normal, mat_z)

	move_x: Vec = normal_x * w
	move_z: Vec = normal_z * w
	
	return {
		from,
		mid + move_z,
		mid + move_x,
	
		from,
		mid - move_x,
		mid + move_z,
	
		from,
		mid + move_x,
		mid - move_z,
	
		from,
		mid - move_z,
		mid - move_x,

		mid + move_x,
		mid + move_z,
		to,

		mid + move_z,
		mid - move_x,
		to,

		mid - move_x,
		mid - move_z,
		to,

		mid - move_z,
		mid + move_x,
		to,
	}
}
