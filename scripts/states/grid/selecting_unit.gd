extends State
class_name SelectingUnit

func enter():
	ref.reset_all_tiles()
	ref.get_node("CanvasLayer").get_node("UnitGui").hide()

func tile_selected():
	enter()

func unit_selected():
	transition.emit(self.name, "SelectingGui")
