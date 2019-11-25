extends KinematicBody

const MOVE_SPEED = 4
const MOUSE_SENS = 0.5
var num_of_levels = 3
var current_hp = 8
var max_hp = 8
var zombies_killed = 0
var key = false

onready var anim_player = $AnimationPlayer
onready var raycast = $RayCast
onready var HUD_zombies_left = $CanvasLayer/HUD_zombies_left
onready var HUD_current_hp = $CanvasLayer/HUD_current_hp
onready var HUD_you_win = $CanvasLayer/HUD_you_win
onready var HUD_key = $CanvasLayer/HUD_key
onready var HUD_no_key = $CanvasLayer/HUD_no_key

func _ready():
	add_to_group("player")
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	yield(get_tree(), "idle_frame")
	get_tree().call_group("zombies", "set_player", self)
	get_tree().call_group("special_zombies", "set_player", self)
	get_tree().call_group("health_boost", "set_player", self)
	get_tree().call_group("health_pack", "set_player", self)
	get_tree().call_group("explosive_barrel", "set_player", self)
	get_tree().call_group("key", "set_player", self)
	get_tree().call_group("door", "set_player", self)
	HUD_current_hp._update_current_hp(current_hp)
	
	

func _input(event):
	if event is InputEventMouseMotion:
		rotation_degrees.y -= MOUSE_SENS * event.relative.x
		rotation_degrees.x -= MOUSE_SENS * event.relative.y
		if deg2rad(rotation_degrees.x) > deg2rad(90):
			rotation_degrees.x = 90
			print("UP boundry")
		elif deg2rad(rotation_degrees.x) < deg2rad(-90):
			#bugs out when I do -90 degrees... looks in the opposite direction
			rotation_degrees.x = -89
			print("DOWN boundry")

func _process(delta):
	if Input.is_action_pressed("exit"):
		get_tree().quit()
	if Input.is_action_pressed("restart"):
		kill()

func _physics_process(delta):
	var move_vec = Vector3()
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
		
		var coll = raycast.get_collider()
		if raycast.is_colliding() and coll.has_method("kill"):
			coll.kill()
			
		elif raycast.is_colliding() and coll.has_method("explode"):
			coll.explode()

func kill():
	current_hp = current_hp - 1
	if current_hp == 100:
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
	yield(get_tree().create_timer(30), "timeout")
	if(current_hp < 5):
		return
	current_hp -= 4
	max_hp -= 4
	HUD_current_hp._update_current_hp(current_hp)

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