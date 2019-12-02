extends Spatial

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().paused = false
	var levelData = _getLevelData( global.current_level )
	
	var arenaSize = levelData.get('arenaSize', null)
	if arenaSize != null:
		_addArena( arenaSize )
	OS.window_fullscreen = true


	var pillar = levelData.get( 'PILLARS', null )
	if pillar != null :
		_addPillars( pillar.get( 'tscn', null ), pillar.get( 'instances', [] ) )
		
	var zombies = levelData.get( 'ZOMBIES', null )
	if zombies != null :
		_addZombies( zombies.get( 'tscn', null ), zombies.get( 'instances', [] ) )
		
	var health_packs = levelData.get ( 'HEALTH_PACK', null)
	if health_packs != null :
		_addHealthPacks( health_packs.get( 'tscn', null ), health_packs.get( 'instances', [] ) )
		
	var super_health_packs = levelData.get ( 'SUPER_HEALTH_PACK', null)
	if super_health_packs != null :
		_addSuper_HealthPacks( super_health_packs.get( 'tscn', null ), super_health_packs.get( 'instances', [] ) )
		
	var barrels = levelData.get ( 'BARRELS', null)
	if barrels != null :
		_addBarrels( barrels.get( 'tscn', null ), barrels.get( 'instances', [] ) )
		
	var zombie_platform = levelData.get ( 'ZOMBIE_PLATFORM', null)
	if zombie_platform != null :
		_addZombiePlatform( zombie_platform.get( 'zombie_tscn', null ), zombie_platform.get( 'platform_tscn', null ), zombie_platform.get( 'instances', [] ), zombie_platform.get( 'zombie_count', null ) )
		
	var KEY_AND_EXIT = levelData.get ( 'KEY_AND_EXIT', null)
	if KEY_AND_EXIT != null :
		_addKeyandExit( KEY_AND_EXIT.get( 'key_tscn', null ), KEY_AND_EXIT.get( 'key_instance', [] ), KEY_AND_EXIT.get( 'door_tscn', null ), KEY_AND_EXIT.get( 'door_instance', [] ))
	
	var instant_kill = levelData.get ( 'INSTANT_KILL_POWER', null)
	if instant_kill != null :
		_addInstantKill( instant_kill.get( 'tscn', null), instant_kill.get( 'instances', []) )
	
func _addArena(arenaSize):
	var wall
	var floorBoundry
	
	if arenaSize == null:
		print('no arenaSize passed...')
		return
		
	var boundryScene = load( "res://Boundry.tscn" )
	
	floorBoundry = boundryScene.instance()
	floorBoundry.scale       = Vector3(arenaSize[0], 1, arenaSize[1])
	get_node( '.' ).add_child( floorBoundry )
	
	wall = boundryScene.instance()
	wall.translation = Vector3( 0, 3, arenaSize[0] )
	wall.scale       = Vector3( arenaSize[0], 3, 2 )
	get_node( '.' ).add_child( wall )

	wall = boundryScene.instance()
	wall.translation = Vector3( 0, 3, -arenaSize[0] )
	wall.scale       = Vector3( arenaSize[0], 3, 2 )
	get_node( '.' ).add_child( wall )
	
	wall = boundryScene.instance()
	wall.translation = Vector3( arenaSize[1], 3, 0 )
	wall.scale       = Vector3( arenaSize[0], 3, 2 )
	wall.rotation_degrees       = Vector3( 0, 90, 0 )
	get_node( '.' ).add_child( wall )
	
	wall = boundryScene.instance()
	wall.translation = Vector3( -arenaSize[1], 3, 0 )
	wall.scale       = Vector3(arenaSize[0], 3, 2)
	wall.rotation_degrees       = Vector3( 0, 90, 0 )
	get_node( '.' ).add_child( wall )
	
	
func _addPillars(model, instances):
	var inst
	var index = 0
	
	if model == null:
		print('no PILLAR model loaded...')
		return
	
	var pillarScene = load(model)
	for instList in instances:
		var position = instList[0]
		inst = pillarScene.instance()
		inst.translation = Vector3( position[0], position[1], position[2] )
		get_node( '.' ).add_child( inst )


func _addZombies(model, instances):
	var inst
	var index = 0
	
	if model == null:
		print('no ZOMBIE model loaded...')
		return
	
	var zombieScene = load(model)
	
	for instList in instances:
		var position = instList[0]
		
		inst = zombieScene.instance()
		inst.translation = Vector3( position[0], position[1], position[2] )
		get_node( '.' ).add_child( inst )
		global.num_of_zombie_in_level = global.num_of_zombie_in_level + 1

func _addKeyandExit(keymodel, keyinstance, doormodel, doorinstance):
	var keyinst
	var doorinst
	var index = 0
	
	if keymodel == null:
		print('no Key model loaded...')
		return
	
	var keyScene = load(keymodel)
	
	if doormodel == null:
		print('no Door model loaded...')
		return
	
	var doorScene = load(doormodel)

	
	for instList in keyinstance:
		var position = instList[0]
		
		keyinst = keyScene.instance()
		keyinst.translation = Vector3( position[0], position[1], position[2] )
		get_node( '.' ).add_child( keyinst )
		
	for instList in doorinstance:
		var position = instList[0]
		
		doorinst = doorScene.instance()
		doorinst.translation = Vector3( position[0], position[1], position[2] )
		get_node( '.' ).add_child( doorinst )


func _addHealthPacks(model, instances):
	var inst
	
	if model == null:
		print('no HEALTH_PACK model loaded...')
		return
	
	var healthPackScene = load(model)
	
	for instList in instances:
		var position = instList[0]
		
		inst = healthPackScene.instance()
		inst.translation = Vector3( position[0], position[1], position[2] )
		get_node( '.' ).add_child( inst )

func _addSuper_HealthPacks( model, instances ):
	var inst
	
	if model == null:
		print('no SUPER_HEALTH_PACK model loaded...')
		return
	
	var superhealthPackScene = load(model)
	
	for instList in instances:
		var position = instList[0]
		
		inst = superhealthPackScene.instance()
		inst.translation = Vector3( position[0], position[1], position[2] )
		get_node( '.' ).add_child( inst )

func _addBarrels(model, instances):
	var inst
	
	if model == null:
		print('no BARREL model loaded...')
		return
	
	var barrelScene = load(model)
	
	for instList in instances:
		var position = instList[0]
		
		inst = barrelScene.instance()
		inst.translation = Vector3( position[0], position[1], position[2] )
		get_node( '.' ).add_child( inst )
		
func _addZombiePlatform(zombie_model, platform_model, instances, zombie_count):
	var inst
	
	if platform_model == null:
		print('no ZOMBIE_PLATFORM model loaded...')
		return
		
	if zombie_model == null:
		print('no ZOMBIE model loaded...')
		return
		
	if zombie_count == null:
		print('no ZOMBIE_COUNT loaded...')
		return
	
	var zombiePlatformScene = load(platform_model)
	
	for instList in instances:
		var position = instList[0]
		inst = zombiePlatformScene.instance()
		inst.translation = Vector3( position[0], position[1], position[2] )
		get_node( '.' ).add_child( inst )
		
func _addInstantKill(model, instances):
	var inst
	
	if model == null:
		print('no INSTANT_KILL model loaded...')
		return
	
	var instantKillScene = load(model)
	for instList in instances:
		var position = instList[0]
		inst = instantKillScene.instance()
		inst.translation = Vector3( position[0], position[1], position[2] )
		get_node( '.' ).add_child( inst )

func _getLevelData( levelNumber ):
	var levelData = {}
	var fName = 'res://Level-%02d.json' % levelNumber
	var file = File.new()
	if file.file_exists( fName ) :
    file.open( fName, file.READ )
    var text_data = file.get_as_text()
    var result_json = JSON.parse( text_data )

    if result_json.error == OK:  # If parse OK
      levelData = result_json.result

    else :
      print( 'Error        : ', result_json.error)
      print( 'Error Line   : ', result_json.error_line)
      print( 'Error String : ', result_json.error_string)
	
	else :
      print( 'Level %d config file did not exist.' % levelNumber )
	
	return levelData