extends Node
class_name Traversal

enum Type {move, select}
enum Direction {step, stride, line, diagonal, straight, horizontal, vertical, N, NE, E, SE, S, SW, W, NW}

@export var type: Type
@export var title: String
@export var direction: Direction
@export var distance: int
@export var exact: bool
@export var relative_facing: bool

@export var traversal_chain: Traversal

#func _ready():
	#if type == Type.move:
		#title = "move"
