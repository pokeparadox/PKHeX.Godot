extends Node

# member variables
#The currently active scene
var current_scene = null

func _ready():
	current_scene = get_tree().get_root().get_child(get_tree().get_root().get_child_count() -1)

func set_scene(scene):
	current_scene.queue_free()
	var s = ResourceLoader.load(scene)
	current_scene = s.instantiate()
	get_tree().get_root().add_child(current_scene)
