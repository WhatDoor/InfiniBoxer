extends Label

var counter = 0

func _on_timer_timeout():
	counter += 1
	text = "Survive: " + str(counter)
