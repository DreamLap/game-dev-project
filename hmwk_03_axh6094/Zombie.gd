extends KinematicBody

const MOVE_SPEED = 3
var HIT_POINTS = 4
var MAX_DIST_TO_HUMAN = 25
var rng = RandomNumberGenerator.new()
onready var raycast = $RayCast
onready var anim_player = $AnimationPlayer

var player = null
var dead = false

var reset_attack = false
var timer = 0
var timer_limit = 1 # seconds


func _ready():
	anim_player.play("walk")
	add_to_group("zombies")
	get_tree().call_group("player", "update_HUD_zombie_count")
	self.set_player()

func _physics_process(delta):
		
	if dead:
		return
	if player == null:
		return
	
	var vec_to_player = player.translation - translation
	var distance_to_player = sqrt(vec_to_player[0] * vec_to_player[0] + vec_to_player[2] * vec_to_player[2])
	if MAX_DIST_TO_HUMAN < distance_to_player:
		vec_to_player[0] = (rng.randf_range(0,100))
		vec_to_player[2] = (rng.randf_range(0,100))
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
	
	var collision_info = move_and_collide(vec_to_player * MOVE_SPEED * delta)
	
	#Zombie falls to ground
	if collision_info == null:
		vec_to_player.y -= 10
		move_and_collide(vec_to_player * MOVE_SPEED * delta)
	
	if raycast.is_colliding():
		var coll = raycast.get_collider()
		if coll != null and coll.name == "Player":
			reset_attack = true
			coll.kill()

func kill():
	if HIT_POINTS > 0:
		HIT_POINTS = HIT_POINTS - 1
	else:
		dead = true
		$CollisionShape.disabled = true
		anim_player.play("die")
		remove_from_group("zombies")
		update_HUD()
		player.add_to_zombie_kill_counter()
		#killed all zombies

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
	print("HP: ", HIT_POINTS)
	print("melee dmg: " ,random_melee_damage)
	HIT_POINTS = HIT_POINTS - random_melee_damage
	
	if HIT_POINTS > 0:
		HIT_POINTS = HIT_POINTS - 1
	else:
		dead = true
		$CollisionShape.disabled = true
		anim_player.play("die")
		remove_from_group("special_zombies")
		update_HUD()
		player.add_to_zombie_kill_counter()
		#killed all zombies
		if player.get_number_of_zombies_killed() == global.num_of_zombie_in_level:
			get_tree().call_group("player", "next_level")