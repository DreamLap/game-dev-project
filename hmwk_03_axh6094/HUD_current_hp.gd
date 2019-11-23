extends Label

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _update_current_hp(current_hp):
	set_text('Current HP: ' + str(current_hp))

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
