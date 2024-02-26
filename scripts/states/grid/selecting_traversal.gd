extends State
class_name SelectingTraversal

var starting_position: Vector2i

func enter():
	starting_position = ref.selected_position

func exit():
	ref.reset_all_tiles()

func tile_selected():
	if ref.get_tile(ref.selected_position).state["traversable"]:
		ref.update_unit_position(starting_position, ref.selected_position)
		ref.selected_position = Vector2(0, 0)
	transition.emit(self.name, "SelectingUnit")

func unit_selected():
	transition.emit(self.name, "SelectingGui")

func traversal_selected(traversal):
	ref.reset_all_tiles()
	ref.traversable_positions = ref.get_traversable_positions(ref.selected_position, traversal)
