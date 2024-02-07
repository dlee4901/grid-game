extends Node2D

@export var sprite: Sprite2D
@export var title: String

@export var move_direction: Util.Direction
@export var move_distance: int
@export var move_exact: bool
@export var move_relative_facing: bool

@export var max_health: int
@export var current_health: int
@export var facing: Util.Facing

@onready var grid_position = Vector2i(-1, -1)

func init(title, move_direction, move_distance, move_exact, move_relative_facing, max_health=0, current_health=0, facing=Util.Facing.N):
	self.title = title
	self.move_direction = move_direction
	self.move_distance = move_distance
	self.move_exact = move_exact
	self.move_relative_facing = move_relative_facing

func load_sprite(path: String):
	sprite = Sprite2D.new()
	sprite.texture = load(path)
	scale.x = 0.125
	scale.y = 0.125
	add_child(sprite)
