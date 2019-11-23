extends Label

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	set_percent_visible(0)

func _player_won():
	set_percent_visible(100)