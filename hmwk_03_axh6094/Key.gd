extends Area
# Key model found on https://sketchfab.com/3d-models/key-a4aca11a2259462f8735a60eead33962
var player = null

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("key")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Area_body_entered(body):
	if body == player:
		remove_from_group("key")
		get_parent().queue_free()
		get_tree().call_group("player", "key_pick_up")


func set_player(p):
	player = p