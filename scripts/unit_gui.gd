extends VBoxContainer
class_name UnitGUI

var button_size: Vector2i
var font_size: int
var traversal_map = {}

signal button_pressed(traversal)

func load_traversals(traversals: Array[Traversal]):
	Util.queue_free_children(self)
	for traversal in traversals:
		var button = Util.load_tree_object(self, Button)
		button.custom_minimum_size = button_size
		button.add_theme_font_size_override("font_size", button_size.x / 4) 
		button.text = traversal.name
		traversal_map[button.text] = traversal
		button.pressed.connect(_on_button_pressed.bind(traversal_map[button.text]))

func _on_button_pressed(traversal):
	button_pressed.emit(traversal)
