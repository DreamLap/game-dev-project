extends Label

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
# Called when the node enters the scene tree for the first time.
func _ready():
	print('current_lvl: ' + str(global.current_level))
	set_text('Current level: ' + str(global.current_level))

func _update_level_counter():
	set_text('Current level: ')
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
