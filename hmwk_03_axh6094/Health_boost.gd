extends Area

var player = null

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("health_boost")

# Called every frame. 'delta' is the elapsed time since the previous frame.



func _on_Area_body_entered(body):
	
	if body == player:
		remove_from_group("health_boost")
		get_tree().call_group("player", "heal_boost")
		get_parent().queue_free()



func set_player(p):
	player = p