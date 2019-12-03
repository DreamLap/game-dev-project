extends KinematicBody

const MOVE_SPEED = 4
const MOUSE_SENS = 0.5
var num_of_levels = 2
var current_hp = 8
var max_hp = 8
var zombies_killed = 0
var key = false
var instant_kill_counter = 0
var instant_kill = false
var inst
var time = 0

onready var anim_player = $AnimationPlayer
onready var raycast = $RayCast
onready var HUD_zombies_left = $CanvasLayer/HUD_zombies_left
onready var HUD_current_hp = $CanvasLayer/HUD_current_hp
onready var HUD_you_win = $CanvasLayer/HUD_you_win
onready var HUD_key = $CanvasLayer/HUD_key
onready var HUD_no_key = $CanvasLayer/HUD_no_key
onready var HUD_instant_kill = $CanvasLayer/HUD_instant_kill
onready var HUD_health_boost = $CanvasLayer/HUD_health_boost

func _ready():
	add_to_group("player")
	_addSword()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	yield(get_tree(), "idle_frame")
	get_tree().call_group("zombies", "set_player", self)
	get_tree().call_group("special_zombies", "set_player", self)
	get_tree().call_group("health_boost", "set_player", self)
	get_tree().call_group("health_pack", "set_player", self)
	get_tree().call_group("instant_kill_power_up", "set_player", self)
	get_tree().call_group("explosive_barrel", "set_player", self)
	get_tree().call_group("key", "set_player", self)
	get_tree().call_group("door", "set_player", self)
	get_tree().call_group("npc", "set_player", self)
	HUD_current_hp._update_current_hp(current_hp)
	
	

func _input(event):
	if event is InputEventMouseMotion:
		rotation_degrees.y -= MOUSE_SENS * event.relative.x
		rotation_degrees.x -= MOUSE_SENS * event.relative.y
		if deg2rad(rotation_degrees.x) > deg2rad(90):
			rotation_degrees.x = 90
		elif deg2rad(rotation_degrees.x) < deg2rad(-90):
			#bugs out when I do -90 degrees... looks in the opposite direction
			rotation_degrees.x = -89

func _process(delta):
	if Input.is_action_pressed("exit"):
		get_tree().quit()
	if Input.is_action_pressed("restart"):
		kill()

func _physics_process(delta):
	var move_vec = Vector3()
	time = time - delta
	if Input.is_action_pressed("move_forwards"):
		move_vec.z -= 1
	if Input.is_action_pressed("move_backwards"):
		move_vec.z += 1
	if Input.is_action_pressed("move_left"):
		move_vec.x -= 1
	if Input.is_action_pressed("move_right"):
		move_vec.x += 1
	
	move_vec = move_vec.normalized()
	move_vec = move_vec.rotated(Vector3(0, 1, 0), rotation.y)
	move_and_collide(move_vec * MOVE_SPEED * delta)
	
	if Input.is_action_pressed("shoot") and !anim_player.is_playing():
		anim_player.play("shoot")
		get_tree().call_group("zombies", "fol_time")
		get_tree().call_group("special_zombies", "fol_time")
		var coll = raycast.get_collider()
		if raycast.is_colliding() and coll.has_method("kill"):
			if instant_kill == true:
				coll.instant_kill_zombie()
			else:
				coll.kill()
			
		elif raycast.is_colliding() and coll.has_method("explode"):
			coll.explode()
			
		elif raycast.is_colliding() and coll.has_method("shot_npc"):
			coll.shot_npc()
	
	if Input.is_action_pressed("melee") and !anim_player.is_playing() and (time<0):
		#add melee animation when created
		time = 1
		swing()
		var coll = raycast.get_collider()
		if coll == null:
			return
		
		var player_vec = global_transform.origin
		var object_vec = coll.global_transform.origin
		
		var distance_to_object = sqrt( pow(player_vec[0] - object_vec[0], 2) + pow(player_vec[2] - object_vec[2], 2) )
		
		if raycast.is_colliding() and coll.has_method("kill") and coll.has_method("recoil") and distance_to_object < 3 :
			if instant_kill == true:
				coll.instant_kill_zombie()
			else:
				coll.recoil()
			
		elif raycast.is_colliding() and coll.has_method("explode") and distance_to_object < 3 :
			coll.explode()

func swing():
	for i in range(100):
		inst.rotation[0] += i
	yield(get_tree().create_timer(0.5), "timeout")
	for i in range(100):
		inst.rotation[0] -= i

func _addSword():
	var index = 0
	var model = "res://Sword.tscn"
	
	if model == null:
		print('no Sword model loaded...')
		return
	
	var swordScene = load(model)
	inst = swordScene.instance()
	inst.translation = Vector3( -1, -0.5, -1.5 )
	get_node( '.' ).add_child( inst )

func kill():
	get_tree().call_group("zombies", "fol_time")
	get_tree().call_group("special_zombies", "fol_time")
	current_hp = current_hp - 1
	if current_hp == 0:
		print('You died.. try again.')
		global.num_of_zombie_in_level = 0
		get_tree().reload_current_scene()
	else:
		HUD_current_hp._update_current_hp(current_hp)
	
func update_HUD_zombie_count():
	HUD_zombies_left._update_zombie_counter()
	
func next_level():
	if global.current_level < num_of_levels:
		global.current_level = global.current_level + 1
		global.num_of_zombie_in_level = 0
		#also updates HUD_current_level
		get_tree().reload_current_scene()
	elif global.current_level == num_of_levels:
		HUD_you_win._player_won()

func heal(amount):
	if (current_hp + amount) > max_hp:
		current_hp = max_hp
	else: 
		current_hp = current_hp + amount
	HUD_current_hp._update_current_hp(current_hp)

func heal_boost():
	current_hp += 4
	max_hp += 4
	HUD_current_hp._update_current_hp(current_hp)
	HUD_health_boost.Health_boost_enable()
	yield(get_tree().create_timer(30), "timeout")
	if(current_hp < 5):
		return
	current_hp -= 4
	max_hp -= 4
	HUD_current_hp._update_current_hp(current_hp)

func instant_kill():
	instant_kill_counter += 1
	instant_kill = true
	HUD_instant_kill.instant_kill_enable()
	yield(get_tree().create_timer(30), "timeout")
	if instant_kill_counter == 1:
		instant_kill = false
	instant_kill_counter -= 1


func get_number_of_zombies_killed():
	return zombies_killed

func add_to_zombie_kill_counter():
	zombies_killed = zombies_killed + 1

func no_key_message():
	HUD_no_key._no_key()
	
func no_key_leave():
	HUD_no_key._exited_area()
	
func key_pick_up():
	key = true
	HUD_key._player_obtained()