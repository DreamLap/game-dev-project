extends Area

var player = null
var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("health_pack")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Area_body_entered(body):
	if body == player:
		remove_from_group("health_pack")
		get_parent().queue_free()
		
		rng.randomize()
		var random_heal_amount = rng.randi_range(1, 6)
		get_tree().call_group("player", "heal", random_heal_amount)


func set_player(p):
	player = p