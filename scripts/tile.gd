extends Area2D
class_name Tile

@onready var sprite = $Sprite2D
@onready var collision = $CollisionShape2D

@onready var offset = Vector2i(collision.shape.size)
@onready var grid_position = Vector2i(0, 0)

var state = {"hovered": false, "traversable": false}

signal selected(grid_position)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("mouse_left_click"):
		if state["hovered"]:
			selected.emit(grid_position)
	highlight()

func _on_mouse_entered():
	set_hovered(true)

func _on_mouse_exited():
	set_hovered(false)
		
func highlight():
	if state["hovered"]:
		sprite.modulate.a = 0.5
	else:
		sprite.modulate.a = 1
	if state["traversable"]:
		sprite.modulate.r = 0
	else:
		sprite.modulate.r = 1

func reset_state():
	state["traversable"] = false
	sprite.set_modulate(Color(1, 1, 1, 1))
	
func set_hovered(val: bool):
	state["hovered"] = val
	
func set_traversable(val: bool):
	state["traversable"] = val
