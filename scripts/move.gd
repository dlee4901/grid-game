extends Node
class_name Move

enum Direction {step, stride, line, diagonal, straight, horizontal, vertical, N, NE, E, SE, S, SW, W, NW}

@export var direction: Direction
@export var distance: int
@export var exact: bool
@export var relative_facing: bool
@export var move_chain: Move
