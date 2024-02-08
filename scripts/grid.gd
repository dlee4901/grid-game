extends Node2D
class_name Grid

var tile_scene = preload("res://scenes/tile.tscn")
var unit_scene = preload("res://scenes/unit.tscn")

@export var max_x: int
@export var max_y: int

enum Terrain {DEFAULT, ROCK, HOLE}

var tiles: Array[Tile]
var units: Array[Unit]
var terrain: Array[Terrain]
var selected_position: Vector2i


# Called when the node enters the scene tree for the first time.
func _ready():
	tiles.resize(max_x * max_y)
	units.resize(max_x * max_y)
	terrain.resize(max_x * max_y)
	selected_position = Vector2i(0, 0)
	init_tiles()
	generate_units()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_tile_selected(grid_position):
	var positions: Array[Vector2i]
	var unit = get_unit(grid_position)
	if not selected_position:
		if unit != null:
			positions = get_traversable_positions(grid_position)
			set_tiles_traversable(positions)
			selected_position = grid_position
		else:
			reset_all_tiles()
	else:
		if get_tile(grid_position).state["traversable"]:
			update_unit_position(selected_position, grid_position)
		selected_position = Vector2i(0, 0)
		reset_all_tiles()

func get_tile(position: Vector2i) -> Tile:
	return tiles[flatten(position)]

func get_unit(position: Vector2i) -> Unit:
	return units[flatten(position)]

func set_tile_position(tile, position: Vector2i, terrain_type=Terrain.DEFAULT):
	if not is_legal_position(position):
		return
	tiles[flatten(position)] = tile
	tile.grid_position = position
	tile.position = tile.offset * position + tile.offset/2
	terrain[flatten(position)] = terrain_type

func update_unit_position(src: Vector2i, dst: Vector2i):
	var unit = get_unit(src)
	if unit == null:
		return
	set_unit_position(unit, dst)
	delete_unit_position(src)

func set_unit_position(unit: Unit, position: Vector2i):
	if not is_legal_position(position):
		return
	units[flatten(position)] = unit
	unit.grid_position = position
	unit.position = get_tile(position).offset * position + get_tile(position).offset/2

func delete_unit_position(position: Vector2i):
	var unit = units[flatten(position)]
	units[flatten(position)] = null

func create_tile() -> Tile:
	var tile = Util.load_tree_scene(self, tile_scene)
	tile.selected.connect(_on_tile_selected)
	return tile

func init_tiles():
	for i in tiles.size():
		set_tile_position(create_tile(), unflatten(i))

func flatten(vector: Vector2i) -> int:
	return (vector.y - 1) * max_x + vector.x - 1

func unflatten(i) -> Vector2i:
	return Vector2i(i % max_x + 1, i / max_x + 1)

func reset_all_tiles():
	for tile in tiles:
		tile.reset_state()
	
func set_tiles_traversable(positions: Array[Vector2i]):
	for i in positions:
		get_tile(i).set_traversable(true)

func generate_units():
	var unit_rook = Util.load_tree_scene(self, unit_scene)
	unit_rook.init("rook", Util.Direction.straight, -1, false, false)
	unit_rook.load_sprite("res://assets/circle-red.png")
	
	var unit_bishop = Util.load_tree_scene(self, unit_scene)
	unit_bishop.init("bishop", Util.Direction.diagonal, -1, false, false)
	unit_bishop.load_sprite("res://assets/circle-blue.png")
	
	var unit_queen = Util.load_tree_scene(self, unit_scene)
	unit_queen.init("queen", Util.Direction.line, -1, false, false)
	unit_queen.load_sprite("res://assets/circle-black.png")
	
	set_unit_position(unit_rook, Vector2i(1, 1))
	set_unit_position(unit_bishop, Vector2i(2, 2))
	set_unit_position(unit_queen, Vector2i(5, 6))

func get_traversable_positions(position: Vector2i) -> Array[Vector2i]:
	var traversal_positions: Array[Vector2i]
	var unit = get_unit(position)
	if not is_legal_position(position) or unit == null:
		return traversal_positions
	var absolute_directions = get_absolute_directions(get_unit(position))
	var xy_directions = get_xy_directions(absolute_directions)
	var valid_positions = get_valid_positions(position, xy_directions, unit.move_distance)
	return valid_positions

func get_valid_positions(initial_position: Vector2i, xy_directions: Array[Vector2i], distance=1) -> Array[Vector2i]:
	var unique_positions = {initial_position:null}
	var valid_positions = [initial_position]
	if distance == -1:
		distance = max(max_x, max_y)
	for i in distance:
		#if i > 0:
			#print(i, valid_positions.slice(8 * (i - 1) + 1))
		for j in xy_directions.size():
			var start_position = initial_position
			if i > 0: 
				start_position = valid_positions[xy_directions.size() * (i - 1) + (j + 1)]
			var target_position = start_position + xy_directions[j]
			if is_legal_position(target_position) and not is_blocked(get_unit(initial_position),  target_position) and not unique_positions.has(target_position):
				valid_positions.append(target_position)
				unique_positions[target_position] = null
			else:
				valid_positions.append(start_position)
	var unique_valid_positions : Array[Vector2i]
	unique_valid_positions.assign(unique_positions.keys())
	return unique_valid_positions

func get_xy_directions(absolute_directions: Array[bool]) -> Array[Vector2i]:
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

func get_absolute_directions(unit: Unit) -> Array[bool]:
	var directions : Array[bool] = [false, false, false, false, false, false, false, false]
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

func is_blocked(unit, position) -> bool:
	if get_unit(position):
		return true
	return false

func is_legal_position(position) -> bool:
	return position.x > 0 and position.y > 0 and position.x <= max_x and position.y <= max_y
