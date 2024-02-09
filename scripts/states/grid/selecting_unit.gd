extends State
class_name SelectingUnit

func enter():
	ref.reset_all_tiles()
	print(ref.unit_gui)
	ref.unit_gui.hide()

func tile_selected():
	enter()

func unit_selected():
	transition.emit(self, "SelectingGui")
