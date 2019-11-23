extends Label

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	var num_of_zombies = str(get_tree().get_nodes_in_group("zombies").size())
	set_text('Zombies left: ' + num_of_zombies)

func _update_zombie_counter():
	var num_of_zombies = str(get_tree().get_nodes_in_group("zombies").size())
	set_text('Zombies left: ' + num_of_zombies)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass