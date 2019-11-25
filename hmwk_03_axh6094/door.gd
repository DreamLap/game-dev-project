extends Area

var player = null

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("door")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Area_body_entered(body):
	if body == player:
		var key = get_node("../Player").get("key")
		print(key)
		if (key == true):
			remove_from_group("door")
			get_parent().queue_free()


func set_player(p):
	player = p