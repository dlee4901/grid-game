extends State
class_name SelectingGui

var unit: Unit

func enter():
	unit = ref.get_unit(ref.selected_position)
	ref.unit_gui.load_traversals(unit)
	ref.unit_gui.show()

func tile_selected():
	transition.emit(self, "SelectingUnit")

func unit_selected():
	enter()

func traversal_selected(traversal):
	ref.trafersable_positions = ref.get_traversable_positions(unit, traversal)
	transition.emit(self, "SelectingTraversal")
