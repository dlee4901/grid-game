extends State
class_name GridIdle

@export var grid: Grid

func enter():
	grid.reset_all_tiles()
	
func exit():
	pass

func update(delta):
	pass
