extends Node2D
class_name Grid

var tile_scene = preload("res://scenes/tile.tscn")
var unit_scene = preload("res://scenes/units/unit.tscn")

@export var max_x: int
@export var max_y: int

@onready var unit_gui = get_node("CanvasLayer").get_node("UnitGui")
@onready var state_machine = get_node("StateMachine")

enum Terrain {DEFAULT, ROCK, HOLE}

var tiles: Array[Tile]
var units: Array[Unit]
var terrain: Array[Terrain]

var selected_position: Vector2i
var move_positions: Array[Vector2i]

signal clear_selected

# Called when the node enters the scene tree for the first time.
func _ready():
	tiles.resize(max_x * max_y)
	units.resize(max_x * max_y)
	terrain.resize(max_x * max_y)
	selected_position = Vector2i(0, 0)
	
	init_tiles()
	init_gui()
	place_units()
	state_machine.init()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_tile_selected(grid_position: Vector2i):
	selected_position = grid_position
	if get_unit(selected_position):
		state_machine.current_state.unit_selected()
	else:
		state_machine.current_state.tile_selected()

func _on_unit_gui_button_pressed(traversal):
	state_machine.current_state.traversal_selected(traversal)

func get_tile(position: Vector2i) -> Tile:
	return tiles[flatten(position)]

func get_unit(position: Vector2i) -> Unit:
	return units[flatten(position)]

func init_gui():
	var tile_size = tiles[0].collision.shape.size.x
	var x_pos = tile_size * max_x + 2 * tile_size
	var y_pos = tile_size
	unit_gui.position = Vector2i(x_pos, y_pos)
	unit_gui.button_size = Vector2i(tile_size * 2, tile_size * 2)

func init_tiles():
	for i in tiles.size():
		set_tile_position(create_tile(), unflatten(i))
		
func create_tile() -> Tile:
	#var tile = Util.load_tree_scene(self, tile_scene)
	var tile = tile_scene.instantiate()
	tile.grid = self
	tile.selected.connect(_on_tile_selected)
	add_child(tile)
	return tile

func set_tile_position(tile: Tile, position: Vector2i, terrain_type=Terrain.DEFAULT):
	if not is_legal_position(position):
		return
	tiles[flatten(position)] = tile
	tile.grid_position = position
	tile.position = tile.offset * position + tile.offset/2
	terrain[flatten(position)] = terrain_type

func reset_all_tiles():
	clear_selected.emit()
	#for tile in tiles:
		#tile.reset_state()

func set_tiles_traversable(positions: Array[Vector2i]):
	for i in positions:
		get_tile(i).set_traversable(true)

func place_units():
	for child in get_children():
		if child is Unit:
			set_unit_position(child, child.grid_position)
			child.z_as_relative = false

func set_unit_position(unit: Unit, position: Vector2i):
	if not is_legal_position(position):
		return
	units[flatten(position)] = unit
	unit.grid_position = position
	unit.position = get_tile(position).offset * position + get_tile(position).offset/2

func delete_unit_position(position: Vector2i):
	var unit = units[flatten(position)]
	units[flatten(position)] = null

func update_unit_position(src: Vector2i, dst: Vector2i):
	var unit = get_unit(src)
	if unit == null:
		return
	delete_unit_position(src)
	set_unit_position(unit, dst)

func flatten(vector: Vector2i) -> int:
	return (vector.y - 1) * max_x + vector.x - 1

func unflatten(i: int) -> Vector2i:
	return Vector2i(i % max_x + 1, i / max_x + 1)

func get_move_positions(position: Vector2i, move: Move) -> Array[Vector2i]:
	var move_positions: Array[Vector2i]
	var unit = get_unit(position)
	if not is_legal_position(position) or unit == null:
		return move_positions
	var absolute_directions = get_absolute_directions(get_unit(position), move)
	var xy_directions = get_xy_directions(absolute_directions)
	if move.direction == Traversal.Direction.step or move.direction == Traversal.Direction.stride:
		move_positions = get_valid_moves_step(position, xy_directions, move)
	else:
		move_positions = get_valid_moves(position, xy_directions, move)
	set_tiles_traversable(move_positions)
	return move_positions

func get_valid_moves_step(initial_position: Vector2i, xy_directions: Array[Vector2i], move: Move) -> Array[Vector2i]:
	var unique_positions = {initial_position: null}
	var valid_positions: Array[Vector2i]
	var distance = move.distance
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

func get_valid_moves(initial_position: Vector2i, xy_directions: Array[Vector2i], move: Move) -> Array[Vector2i]:
	var unique_positions = {}
	var valid_positions: Array[Vector2i]
	var distance = move.distance
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

func get_absolute_directions(unit: Unit, traversal: Traversal) -> Array[bool]:
	var directions : Array[bool] = [false, false, false, false, false, false, false, false]
	match traversal.direction:
		Traversal.Direction.stride, Traversal.Direction.line:
			for i in range(0, 8):
				directions[i] = true
		Traversal.Direction.diagonal:
			for i in range(0, 8):
				if i % 2 == 1:
					directions[i] = true
		Traversal.Direction.step, Traversal.Direction.straight:
			for i in range(0, 8):
				if i % 2 == 0:
					directions[i] = true
		Traversal.Direction.horizontal:
			directions[2] = true;
			directions[6] = true;
		Traversal.Direction.vertical:
			directions[0] = true;
			directions[4] = true;
		Traversal.Direction.N:
			directions[0] = true;
		Traversal.Direction.NE:
			directions[1] = true;
		Traversal.Direction.E:
			directions[2] = true;
		Traversal.Direction.SE:
			directions[3] = true;
		Traversal.Direction.S:
			directions[4] = true;
		Traversal.Direction.SW:
			directions[5] = true;
		Traversal.Direction.W:
			directions[6] = true;
		Traversal.Direction.NW:
			directions[7] = true;
		_:
			print("grid::get_absolute_directions() - Invalid direction")
	if traversal.relative_facing:
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
