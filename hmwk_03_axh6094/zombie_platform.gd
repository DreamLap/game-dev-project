extends Spatial

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var x_global_platform_location = null
var y_global_platform_location = null
var z_global_platform_location = null
var explodeScene = load( "res://Barrel_explosion.tscn" )
var zombieScene = load( "res://Zombie.tscn" )
var specialZombieScene = load( "res://special_zombie.tscn" )
var rng = RandomNumberGenerator.new()
var time_check = 5
var timer = 0

var platform_hp = 2
# Called when the node enters the scene tree for the first time.
func _ready():
	var platform_position = global_transform.origin
	x_global_platform_location = platform_position[0]
	y_global_platform_location = platform_position[1]
	z_global_platform_location = platform_position[2]
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	timer = timer + delta
	if time_check < timer:
		var inst
		rng.randomize()
		var rand_number = rng.randi_range(0,1)
		if rand_number == 0:
			inst = zombieScene.instance()
		elif rand_number == 1:
			inst = specialZombieScene.instance()
		get_node('../../..').add_child( inst )
		inst.translation = Vector3( x_global_platform_location, y_global_platform_location + 2, z_global_platform_location )
		timer = 0
		if time_check != 0.5:
			time_check = time_check - 0.5

func explode():
	platform_hp = platform_hp - 1
	
	if platform_hp == 0:
		var platform_vec = global_transform.origin
		var explosion_inst = explodeScene.instance()
		explosion_inst.translation = Vector3( platform_vec[0], platform_vec[1], platform_vec[2] )
		get_node('../../..').add_child( explosion_inst )
		yield(get_tree().create_timer(0.2), "timeout")
		get_node('../../..').remove_child( explosion_inst )
		
		get_parent().get_parent().queue_free()

