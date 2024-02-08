extends Node

func load_tree_object(tree, object):
	var child = object.new()
	tree.add_child(child)
	return child

func load_tree_scene(tree, scene):
	var child = scene.instantiate()
	tree.add_child(child)
	return child
