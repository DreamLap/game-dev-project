extends KinematicBody

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
const MOVE_SPEED = 3
var player = null
var shot_at = false
var dead = false
var NPC_hp = 3
# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("npc")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if dead:
		return
	var npc_vec = global_transform.origin
	var closest_zombie_dist = 100
	var closest_zombie_vec = Vector3(0, 0, 0)
	var theta = rotation.y
	
	var normal_zombies = get_tree().get_nodes_in_group("zombies")
	for inst in normal_zombies:
		var inst_location = inst.global_transform.origin
		var distance_to_zombie = sqrt( pow(inst_location[0] - npc_vec[0], 2) + pow(inst_location[2] - npc_vec[2], 2) )
		if (distance_to_zombie < closest_zombie_dist):
			var new_vec = inst_location - npc_vec
			closest_zombie_dist = distance_to_zombie
			closest_zombie_vec[0] = new_vec[0]
			closest_zombie_vec[2] = new_vec[2]
			
			
			
	var special_zombies = get_tree().get_nodes_in_group("special_zombies")
	for inst in special_zombies:
		var inst_location = inst.global_transform.origin
		var distance_to_zombie = sqrt( pow(inst_location[0] - npc_vec[0], 2) + pow(inst_location[2] - npc_vec[2], 2) )
		if (distance_to_zombie < closest_zombie_dist):
			var new_vec = inst_location - npc_vec
			closest_zombie_dist = distance_to_zombie
			closest_zombie_vec[0] = new_vec[0]
			closest_zombie_vec[2] = new_vec[2]
			
			
	closest_zombie_vec[0] = -closest_zombie_vec[0]
	closest_zombie_vec[1] = 0
	closest_zombie_vec[2] = -closest_zombie_vec[2]
	if closest_zombie_vec[2] != 0:
		theta = atan(closest_zombie_vec[0] / closest_zombie_vec[2])
	
	#run away from closest zombie
	if (closest_zombie_dist < 20):
		rotation_degrees.y = rad2deg( -theta )
		move_and_collide(closest_zombie_vec * MOVE_SPEED * delta)
		return
	
	#will run from player if shot at and no zombies present
	if shot_at == true:

		var vec_to_player = player.translation - translation
		vec_to_player = vec_to_player.normalized()
		vec_to_player[0] = -vec_to_player[0]
		vec_to_player[1] = 0
		vec_to_player[2] = -vec_to_player[2]
		move_and_collide(vec_to_player * MOVE_SPEED * delta)

func shot_npc():
	shot_at = true
	NPC_hp = NPC_hp - 1
	if NPC_hp <= 0:
		dead = true
		rotation.z = rad2deg(40)
		rotation.x = rad2deg(40)
		$CollisionShape.disabled = true
		remove_from_group("npc")
		return


func set_player(p):
	player = p