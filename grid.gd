extends Node2D

const Tile = preload("res://tile.tscn")
const Unit = preload("res://units/unit.tscn")

@export var max_x: int
@export var max_y: int

var tiles: Array
var units: Array

var selected_unit

# Called when the node enters the scene tree for the first time.
func _ready():
	tiles.resize(max_x * max_y)
	units.resize(max_x * max_y)
	generate_tiles()
	generate_units()
	selected_unit == null

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_tile_selected(grid_position):
	var positions: Array[Vector2i]
	var unit = get_unit(grid_position)
	if selected_unit == null:
		if unit != null:
			positions = get_traversable_positions(grid_position)
			set_tiles_traversable(positions)
			selected_unit = unit
		else:
			reset_all_tiles()
	else:
		if get_tile(grid_position).state["traversable"]:
			set_unit_position(selected_unit, grid_position)
		selected_unit = null
		reset_all_tiles()

func get_tile(position: Vector2i):
	return tiles[flatten(position)]

func get_unit(position: Vector2i):
	return units[flatten(position)]

func set_tile_position(tile, position: Vector2i):
	tiles[flatten(position)] = tile
	tile.grid_position = position
	tile.position = tile.offset * position + tile.offset/2

func set_unit_position(unit, position: Vector2i):
	units[flatten(position)] = unit
	unit.grid_position = position
	unit.position = get_tile(position).offset * position + get_tile(position).offset/2

func delete_unit_position(position: Vector2i):
	var unit = units[flatten(position)]
	units.remove_at(flatten(position))
	unit.queue_free()

func create_tile():
	var tile = Util.load_tree_scene(self, Tile)
	tile.selected.connect(_on_tile_selected)
	return tile
	
func generate_units():
	var unit_rook = Util.load_tree_scene(self, Unit)
	unit_rook.init("rook", Util.Direction.straight, -1, false, false)
	unit_rook.load_sprite("res://assets/circle-red.png")
	
	var unit_bishop = Util.load_tree_scene(self, Unit)
	unit_bishop.init("bishop", Util.Direction.diagonal, -1, false, false)
	unit_bishop.load_sprite("res://assets/circle-blue.png")
	
	var unit_queen = Util.load_tree_scene(self, Unit)
	unit_queen.init("queen", Util.Direction.line, -1, false, false)
	unit_queen.load_sprite("res://assets/circle-black.png")
	
	set_unit_position(unit_rook, Vector2i(0, 0))
	set_unit_position(unit_bishop, Vector2i(2, 2))
	set_unit_position(unit_queen, Vector2i(5, 6))

func generate_tiles():
	for x in range(0, max_x):
		for y in range(0, max_y):
			set_tile_position(create_tile(), Vector2i(x, y))

func flatten(vector: Vector2i):
	return vector.x * max_x + vector.y

func unflatten(i):
	return Vector2i(i % max_x, i / max_x)

func reset_all_tiles():
	for tile in tiles:
		tile.reset_state()
	
func set_tiles_traversable(positions: Array[Vector2i]):
	for i in positions:
		get_tile(i).set_traversable(true)

func get_traversable_positions(position: Vector2i):
	var traversable_positions: Array[Vector2i]
	var unit = get_unit(position)
	if unit != null:
		var absolute_directions = get_absolute_directions(unit)
		var xy_directions = get_xy_directions(absolute_directions)
		var new_positions = matrix_add(xy_directions, position, unit.move_distance)
		var valid_positions = get_valid_positions(new_positions)
		traversable_positions = valid_positions
	return traversable_positions
	
func get_valid_positions(positions: Array[Vector2i]):
	var valid_positions: Array[Vector2i]
	var dict = {}
	for i in range(0, positions.size()):
		if positions[i].x >= 0 and positions[i].y >= 0 and positions[i].x < max_x and positions[i].y < max_y:
			if not dict.has(positions[i]):
				dict[positions[i]] = 0
				valid_positions.append(positions[i])
	return valid_positions

# TODO does not account for unit collision
func matrix_add(matrix: Array[Vector2i], vector: Vector2i, iterations=1):
	var new_matrix: Array[Vector2i]
	if iterations < 0:
		iterations = max_x
	new_matrix.resize(8 * iterations)
	new_matrix.fill(vector)
	for i in range(0, iterations):
		var start_index = 8 * i
		for j in range(start_index, start_index + 8):
			new_matrix[j] = new_matrix[j - 8] + matrix[j - start_index]
	return new_matrix

func get_xy_directions(absolute_directions):
	var xy_directions: Array[Vector2i]
	for i in range(0, 8):
		var x = 0
		var y = 0
		if absolute_directions[i]:
			if i > 4:
				x = -1
			elif i > 0 and i < 4:
				x = 1
			if i > 2 and i < 6:
				y = 1
			elif i < 2 or i > 6:
				y = -1
		xy_directions.append(Vector2i(x, y))
	return xy_directions

func get_absolute_directions(unit):
	var directions = [false, false, false, false, false, false, false, false]
	match unit.move_direction:
		Util.Direction.stride, Util.Direction.line:
			for i in range(0, 8):
				directions[i] = true
		Util.Direction.diagonal:
			for i in range(0, 8):
				if i % 2 == 1:
					directions[i] = true
		Util.Direction.step, Util.Direction.straight:
			for i in range(0, 8):
				if i % 2 == 0:
					directions[i] = true
		Util.Direction.horizontal:
			directions[2] = true;
			directions[6] = true;
		Util.Direction.vertical:
			directions[0] = true;
			directions[4] = true;
		Util.Direction.N:
			directions[0] = true;
		Util.Direction.NE:
			directions[1] = true;
		Util.Direction.E:
			directions[2] = true;
		Util.Direction.SE:
			directions[3] = true;
		Util.Direction.S:
			directions[4] = true;
		Util.Direction.SW:
			directions[5] = true;
		Util.Direction.W:
			directions[6] = true;
		Util.Direction.NW:
			directions[7] = true;
		_:
			print("grid::get_absolute_directions() - Invalid direction")
	if unit.move_relative_facing:
		var shift = 0
		match unit.facing:
			Util.Facing.N:
				shift == 0
			Util.Facing.E:
				shift == 6
			Util.Facing.S:
				shift == 4
			Util.Facing.W:
				shift == 2
			_:
				print("grid::get_absolute_directions() - Invalid facing")
		return directions.slice(shift) + directions.slice(0, shift)
	return directions
