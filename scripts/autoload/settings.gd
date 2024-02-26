extends Node

var screen_size = Vector2i(1920, 1080)

# Called when the node enters the scene tree for the first time.
func _ready():
	init_window()
	init_inputs()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# https://docs.godotengine.org/en/stable/tutorials/rendering/multiple_resolutions.html
# https://docs.godotengine.org/en/stable/classes/class_window.html#enum-window-contentscalemode
func init_window():
	get_tree().root.content_scale_size = screen_size
	get_tree().root.content_scale_mode = 1     # disabled, canvas-items, viewport
	get_tree().root.content_scale_aspect = 4   # ignore, keep, keep width, keep height, expand
	get_tree().root.content_scale_stretch = 0  # fractional, integer
	get_tree().get_root().set_min_size(screen_size)

func init_inputs():
	var mouse_left_click = InputEventMouseButton.new()
	mouse_left_click.button_index = 1
	InputMap.add_action("mouse_left_click")
	InputMap.action_add_event("mouse_left_click", mouse_left_click)
	
	var key_w = InputEventKey.new()
	key_w.key_label = KEY_W
	InputMap.add_action("key_w")
	InputMap.action_add_event("key_w", key_w)
