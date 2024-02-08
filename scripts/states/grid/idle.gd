extends State
class_name GridIdle

@export var grid: Grid

func enter():
	grid.reset_all_tiles()
	print("idle")
	
func exit():
	pass

func update(delta):
	pass

func _on_tile_selected(grid_position):
	print(grid_position)
