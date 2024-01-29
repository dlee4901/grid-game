extends Node

var screen_size = Vector2i(1920, 1080)

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().root.get_viewport().set_size(screen_size)
	get_tree().root.get_viewport().set_content_scale_mode(1) 	# stretch_mode = canvas_items
	get_tree().root.get_viewport().set_content_scale_aspect(1) 	# stretch_aspect = keep

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
