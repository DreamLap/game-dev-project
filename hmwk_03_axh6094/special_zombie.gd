extends KinematicBody

const MOVE_SPEED = 3
var HIT_POINTS = 4
var MAX_DIST_TO_HUMAN = 25
var rng = RandomNumberGenerator.new()
onready var raycast = $RayCast
onready var anim_player = $AnimationPlayer

var explodeScene = load( "res://Barrel_explosion.tscn" )

var player = null
var dead = false
var collision_info = Vector3(0,0,0)
var reset_attack = false
var timer = 0
var time = 0
var timer_limit = 1 # seconds
var dir = 0
var temp1
var temp2


func _ready():
	anim_player.play("walk")
	add_to_group("special_zombies")
	get_tree().call_group("player", "update_HUD_zombie_count")
	self.set_player()

func _physics_process(delta):
	if dead:
		return
	if player == null:
		return
	var vec_to_player = player.translation - translation
	var distance_to_player = sqrt(vec_to_player[0] * vec_to_player[0] + vec_to_player[2] * vec_to_player[2])
	
	vec_to_player = vec_to_player.normalized()
	raycast.cast_to = vec_to_player * 1.5
	
	if reset_attack == true:
		vec_to_player[0] = -vec_to_player[0]
		vec_to_player[2] = -vec_to_player[2]
		move_and_collide(vec_to_player * MOVE_SPEED * delta)
		timer += delta
		if timer > timer_limit :
			reset_attack = false
			timer = 0
		return
	
	if MAX_DIST_TO_HUMAN > distance_to_player:
		follow(vec_to_player, MOVE_SPEED, delta)
	else:
		wander(vec_to_player, MOVE_SPEED, delta)
	
	#Zombie falls to ground
	if collision_info == null:
		vec_to_player.y -= 10
		move_and_collide(vec_to_player * MOVE_SPEED * delta)
	
	if raycast.is_colliding():
		var coll = raycast.get_collider()
		if coll != null and coll.name == "Player":
			reset_attack = true
			coll.kill()


func follow(vec, spd, del):
	time = 0
	collision_info = move_and_collide(vec * spd * del)

func wander(vec, spd, del):
	if(time > 10):
		dir = 0
		wait(del)
		return
	time = time + del
	if dir == 0:
		temp1 = (rand_range(-100,100))
		temp2 = (rand_range(-100,100))
		dir = 1
	vec[0] = temp1
	vec[2] = temp2
	vec = vec.normalized()
	collision_info = move_and_collide(vec * spd * del)


func wait(del):
	if (time > 20):
		time = 0
		return
	time = time + del
	collision_info = move_and_collide(Vector3(0,0,0))
	

func kill():
	if HIT_POINTS > 0:
		HIT_POINTS = HIT_POINTS - 1
	else:
		dead = true
		$CollisionShape.disabled = true
		anim_player.play("die")
		remove_from_group("special_zombies")
		explode()
		update_HUD()
		player.add_to_zombie_kill_counter()
		#killed all zombies

func explode():
	var special_zombie_pos = global_transform.origin
	var player_vec = player.global_transform.origin
	var player_dist_to_zombie = player_vec.distance_to(special_zombie_pos)
	
	
	#creates explosion
	var explosion_inst = explodeScene.instance()
	explosion_inst.translation = Vector3( special_zombie_pos[0], special_zombie_pos[1], special_zombie_pos[2] )
	get_node('../..').add_child( explosion_inst )
	yield(get_tree().create_timer(0.2), "timeout")
	get_node('../..').remove_child( explosion_inst )
	
	#damages nearby player
	if player_dist_to_zombie < 4:
		player.kill()
		
	#damages nearby zombies
	var zombies = get_tree().get_nodes_in_group("zombies")
	for inst in zombies:
		var zombie_vec = inst.global_transform.origin
		var zombie_dist_to_zombie = zombie_vec.distance_to(special_zombie_pos)
		if zombie_dist_to_zombie < 4:
			inst.kill()
			
	
	#damages nearby barrels
	var barrels = get_tree().get_nodes_in_group("explosive_barrel")
	for inst in barrels:
		var inst_barrel_vec = inst.global_transform.origin
		var barrel_dist_to_zombie = inst_barrel_vec.distance_to(special_zombie_pos)
		if barrel_dist_to_zombie < 4:
			inst.explode()
	
	#damage nearby special zombies
	var special_zombies = get_tree().get_nodes_in_group("special_zombies")
	for inst in special_zombies:
		if inst == self:
			#skips self referencing barrel
			continue
			
		var inst_special_vec = inst.global_transform.origin
		var special_dist_to_special = inst_special_vec.distance_to(special_zombie_pos)
		if special_dist_to_special < 4:
			inst.kill()


func set_player():
	for player_nodes in get_tree().get_nodes_in_group('player'):
		player = player_nodes
		return
	return
	
func update_HUD():
	get_tree().call_group("player", "update_HUD_zombie_count")
	
func recoil():
	reset_attack = true
	timer = 0
	rng.randomize()
	var random_melee_damage = rng.randi_range(1, 4)
	HIT_POINTS = HIT_POINTS - random_melee_damage
	
	if HIT_POINTS > 0:
		HIT_POINTS = HIT_POINTS - 1
	else:
		dead = true
		$CollisionShape.disabled = true
		anim_player.play("die")
		remove_from_group("special_zombies")
		explode()
		update_HUD()
		player.add_to_zombie_kill_counter()
		#killed all zombies
		if player.get_number_of_zombies_killed() == global.num_of_zombie_in_level:
			get_tree().call_group("player", "next_level")
			
func instant_kill_zombie():
	dead = true
	$CollisionShape.disabled = true
	anim_player.play("die")
	remove_from_group("zombies")
	explode()
	update_HUD()
	player.add_to_zombie_kill_counter()