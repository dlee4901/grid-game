extends State
class_name SelectingTraversal

var unit: Unit
var starting_position: Vector2i

func enter():
	unit = ref.get_unit(ref.selected_position)
	starting_position = ref.selected_position

func tile_selected():
	if ref.selected_position.state["traversable"]:
		ref.update_unit_position(starting_position, ref.selected_position)
		ref.selected_position = Vector2(0, 0)
	transition.emit(self, "SelectingUnit")

func unit_selected():
	transition.emit(self, "SelectingGui")

func traversal_selected(traversal):
	ref.trafersable_positions = ref.get_traversable_positions(unit, traversal)
