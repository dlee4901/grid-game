extends Node2D

const Camera = preload("res://scenes/camera.tscn")
const Grid = preload("res://scenes/grid.tscn")

var game_mode
var game_state
var camera
var grid

# Called when the node enters the scene tree for the first time.
func _ready():
	load_tree()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func load_tree():
	camera = Util.load_tree_scene(self, Camera)
	grid = Util.load_tree_scene(self, Grid)
