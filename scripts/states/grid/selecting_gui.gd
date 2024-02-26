extends State
class_name SelectingGui

func enter():
	var unit_traversals = ref.get_unit(ref.selected_position).traversals
	ref.unit_gui.load_traversals(unit_traversals)
	ref.unit_gui.show()

func tile_selected():
	transition.emit(self.name, "SelectingUnit")

func unit_selected():
	print("Unitselected")
	enter()

func traversal_selected(traversal):
	ref.traversable_positions = ref.get_traversable_positions(ref.selected_position, traversal)
	transition.emit(self.name, "SelectingTraversal")
