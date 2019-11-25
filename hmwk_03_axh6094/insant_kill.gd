extends Area

var player = null
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("instant_kill_power_up")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Area_body_entered(body):
	if body == player:
		remove_from_group("instant_kill_power_up")
		get_parent().queue_free()
		get_tree().call_group("player", "instant_kill")
		print("hello!!")

func set_player(p):
	player = p