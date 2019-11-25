extends Label

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
func _ready():
	set_percent_visible(0)

func _exited_area():
	set_percent_visible(0)

func _no_key():
	set_percent_visible(100)