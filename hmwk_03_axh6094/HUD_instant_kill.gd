extends Label

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var power_up_time_limit = 30
var time_lapsed = 0
var timer = 0
var counter = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	set_percent_visible(0)
	set_text('Instant kill: ' )

func instant_kill_enable():
	counter += 1
	time_lapsed = 0
	timer = 0
	set_percent_visible(100)
	yield(get_tree().create_timer(30), "timeout")
	if counter == 1:
		set_percent_visible(0)
		time_lapsed = 0
		timer = 0
	counter -=1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	timer += delta 
	time_lapsed = power_up_time_limit - timer
	set_text('Instant kill: ' + str(time_lapsed) )