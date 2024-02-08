extends Node

enum Facing {N, E, S, W}
enum Direction {stride, step, line, diagonal, straight, horizontal, vertical, N, NE, E, SE, S, SW, W, NW}

func load_tree_object(tree, object):
	var child = object.new()
	tree.add_child(child)
	return child

func load_tree_scene(tree, scene):
	var child = scene.instantiate()
	tree.add_child(child)
	return child
