extends Label

signal timeout

var time = 300

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_timer_timeout():
	time -= 1
	
	if (time == 0):
		set_text("You Win!")
		$Timer.stop()
		timeout.emit()
	else:
		set_text("Survive: " + String.num(time))
