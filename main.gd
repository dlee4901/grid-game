extends Node2D

const GameMode = preload("res://game_mode.gd")
const GameState = preload("res://game_state.gd")

const Camera = preload("res://camera.tscn")
const Grid = preload("res://grid.tscn")

var game_mode
var game_state
var camera
var grid

# Called when the node enters the scene tree for the first time.
func _ready():
	load_tree()
	set_inputs()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func load_tree():
	game_mode = Util.load_tree_script(self, GameMode)
	game_state = Util.load_tree_script(self, GameState)
	camera = Util.load_tree_scene(self, Camera)
	grid = Util.load_tree_scene(self, Grid)

func set_inputs():
	var mouse_button = InputEventMouseButton.new()
	mouse_button.button_index = 1
	InputMap.add_action("mouse_left_click")
	InputMap.action_add_event("mouse_left_click", mouse_button)
