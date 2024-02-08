extends Node2D
class_name Grid

var tile_scene = preload("res://scenes/tile.tscn")
var unit_scene = preload("res://scenes/units/unit.tscn")

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
	place_units()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_tile_selected(grid_position: Vector2i):
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

func place_units():
	for child in get_children():
		if child is Unit:
			set_unit_position(child, child.grid_position)
			child.z_as_relative = false

func get_tile(position: Vector2i) -> Tile:
	return tiles[flatten(position)]

func get_unit(position: Vector2i) -> Unit:
	return units[flatten(position)]

func set_tile_position(tile: Tile, position: Vector2i, terrain_type=Terrain.DEFAULT):
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
	delete_unit_position(src)
	set_unit_position(unit, dst)

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

func unflatten(i: int) -> Vector2i:
	return Vector2i(i % max_x + 1, i / max_x + 1)

func reset_all_tiles():
	for tile in tiles:
		tile.reset_state()
	
func set_tiles_traversable(positions: Array[Vector2i]):
	for i in positions:
		get_tile(i).set_traversable(true)

func get_traversable_positions(position: Vector2i) -> Array[Vector2i]:
	var traversal_positions: Array[Vector2i]
	var unit = get_unit(position)
	if not is_legal_position(position) or unit == null:
		return traversal_positions
	var absolute_directions = get_absolute_directions(get_unit(position))
	var xy_directions = get_xy_directions(absolute_directions)
	var valid_positions: Array[Vector2i]
	if unit.move.direction == Move.Direction.step or unit.move.direction == Move.Direction.stride:
		valid_positions = get_valid_positions_step(position, xy_directions, unit)
	else:
		valid_positions = get_valid_positions(position, xy_directions, unit)
	return valid_positions

func get_valid_positions_step(initial_position: Vector2i, xy_directions: Array[Vector2i], unit: Unit) -> Array[Vector2i]:
	var unique_positions = {initial_position: null}
	var valid_positions: Array[Vector2i]
	var distance = unit.move.distance
	if distance == -1:
		distance = max(max_x, max_y)
	for i in distance+1:
		for j in valid_positions:
			for k in xy_directions:
				var target_position = j + k
				if is_legal_position(target_position) and not is_blocked(get_unit(initial_position), target_position) and not unique_positions.has(target_position):
					unique_positions[target_position] = null
		valid_positions.assign(unique_positions.keys())
	valid_positions.erase(initial_position)
	return valid_positions

func get_valid_positions(initial_position: Vector2i, xy_directions: Array[Vector2i], unit: Unit) -> Array[Vector2i]:
	var unique_positions = {}
	var valid_positions: Array[Vector2i]
	var distance = unit.move.distance
	if distance == -1:
		distance = max(max_x, max_y)
	for i in distance:
		#if i > 0:
			#print(i, valid_positions.slice(8 * (i - 1) + 1))
		for j in xy_directions.size():
			var start_position = initial_position
			if i > 0: 
				start_position = valid_positions[xy_directions.size() * (i - 1) + j]
			var target_position = start_position + xy_directions[j]
			if is_legal_position(target_position) and not is_blocked(get_unit(initial_position), target_position) and not unique_positions.has(target_position):
				valid_positions.append(target_position)
				unique_positions[target_position] = null
			else:
				valid_positions.append(start_position)
	valid_positions.assign(unique_positions.keys())
	return valid_positions

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
	match unit.move.direction:
		Move.Direction.stride, Move.Direction.line:
			for i in range(0, 8):
				directions[i] = true
		Move.Direction.diagonal:
			for i in range(0, 8):
				if i % 2 == 1:
					directions[i] = true
		Move.Direction.step, Move.Direction.straight:
			for i in range(0, 8):
				if i % 2 == 0:
					directions[i] = true
		Move.Direction.horizontal:
			directions[2] = true;
			directions[6] = true;
		Move.Direction.vertical:
			directions[0] = true;
			directions[4] = true;
		Move.Direction.N:
			directions[0] = true;
		Move.Direction.NE:
			directions[1] = true;
		Move.Direction.E:
			directions[2] = true;
		Move.Direction.SE:
			directions[3] = true;
		Move.Direction.S:
			directions[4] = true;
		Move.Direction.SW:
			directions[5] = true;
		Move.Direction.W:
			directions[6] = true;
		Move.Direction.NW:
			directions[7] = true;
		_:
			print("grid::get_absolute_directions() - Invalid direction")
	if unit.move.relative_facing:
		var shift = 0
		match unit.facing:
			Unit.Facing.N:
				shift == 0
			Unit.Facing.E:
				shift == 6
			Unit.Facing.S:
				shift == 4
			Unit.Facing.W:
				shift == 2
			_:
				print("grid::get_absolute_directions() - Invalid facing")
		return directions.slice(shift) + directions.slice(0, shift)
	return directions

func is_blocked(unit: Unit, position: Vector2i) -> bool:
	if get_unit(position):
		return true
	return false

func is_legal_position(position: Vector2i) -> bool:
	return position.x > 0 and position.y > 0 and position.x <= max_x and position.y <= max_y
