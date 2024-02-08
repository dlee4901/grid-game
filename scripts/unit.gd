extends Node2D
class_name Unit

@export var title: String
@export var grid_position: Vector2i

@export var max_health: int
@export var current_health: int
@export var facing: Facing

var move: Move

enum Facing {N, E, S, W}

func _ready():
	for child in get_children():
		if child is Move:
			move = child
