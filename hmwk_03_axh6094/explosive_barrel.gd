extends StaticBody

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var barrel_hp = 2
var player = null
var explodeScene = load( "res://Barrel_explosion.tscn" )
# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("explosive_barrel")


func explode():
	get_tree().call_group("zombies", "fol_time")
	get_tree().call_group("special_zombies", "fol_time")
	barrel_hp = barrel_hp - 1
	
	if barrel_hp <= 0:
		var barrel_vec = global_transform.origin
		var player_vec = player.global_transform.origin
		var player_dist_to_barrel = player_vec.distance_to(barrel_vec)
		
		#damages nearby zombies
		var zombies = get_tree().get_nodes_in_group("zombies")
		for inst in zombies:
			var zombie_vec = inst.global_transform.origin
			var zombie_dist_to_barrel = zombie_vec.distance_to(barrel_vec)
			if zombie_dist_to_barrel < 4:
				inst.kill()
			
		#damages nearby player
		if player_dist_to_barrel < 4:
			player.kill()
			
		#damages nearby barrels
		var barrels = get_tree().get_nodes_in_group("explosive_barrel")
		for inst in barrels:
			
			if inst == self:
				#skips self referencing barrel
				continue
			
			var inst_barrel_vec = inst.global_transform.origin
			var barrel_dist_to_barrel = inst_barrel_vec.distance_to(barrel_vec)
			if barrel_dist_to_barrel < 4:
				inst.explode()
		
		#damage nearby special zombies
		var special_zombies = get_tree().get_nodes_in_group("special_zombies")
		for inst in special_zombies:
			if inst == self:
				#skips self referencing barrel
				continue
			var inst_special_vec = inst.global_transform.origin
			var special_dist_to_barrel = inst_special_vec.distance_to(barrel_vec)
			if special_dist_to_barrel < 4:
				inst.kill()
	
		#damage nearby npcs
		var npc = get_tree().get_nodes_in_group("npc")
		for inst in npc:
			if inst == self:
				#skips self referencing barrel
				continue
			
			var inst_npc_vec = inst.global_transform.origin
			var npc_dist_to_barrel = inst_npc_vec.distance_to(barrel_vec)
			if npc_dist_to_barrel < 4:
				inst.shot_npc()
		
		var explosion_inst = explodeScene.instance()
		explosion_inst.translation = Vector3( barrel_vec[0], barrel_vec[1], barrel_vec[2] )
		get_node('../../..').add_child( explosion_inst )
		yield(get_tree().create_timer(0.2), "timeout")
		get_node('../../..').remove_child( explosion_inst )
		
		get_parent().get_parent().queue_free()
		
func set_player(p):
	player = p