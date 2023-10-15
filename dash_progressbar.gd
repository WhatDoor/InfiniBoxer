extends TextureProgressBar

@export var player: CharacterBody2D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	visible = player.dash_boots_enabled
	value = 300 - (player.dash_reset_timer.time_left * 100)
