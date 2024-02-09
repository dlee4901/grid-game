extends VBoxContainer
class_name UnitGUI

var buttons: Array[Button]

signal button_pressed(traversal)

func load_traversals(traversals: Array[Traversal]):
	for traversal in traversals:
		var button = Util.load_tree_object(self, Button)
		button.text = traversal.name
		button.pressed.connect(_on_button_pressed.bind(button.text))

func _on_button_pressed(button):
	button_pressed.emit(button)
