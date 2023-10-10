extends Area2D

@onready var sprite = $Sprite2D
var current_x_scale = -1
var order = 1

func _draw():
	draw_circle(Vector2(0, 4), 10.0, Color.DIM_GRAY)

#Make the power item spin
func _process(delta):
	if (order):
		current_x_scale += delta
	else:
		current_x_scale -= delta
		
	if (current_x_scale >= 1):
		order = 0
	elif (current_x_scale <= -1):
		order = 1
	
	sprite.scale.x = current_x_scale

func collected():
	sprite.hide()
