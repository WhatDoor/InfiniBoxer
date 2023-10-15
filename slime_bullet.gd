extends Area2D

const SPEED = 2.5
var direction: Vector2

func init(given_position: Vector2, given_direction: Vector2):
	position = given_position
	direction = given_direction

func _physics_process(_delta):
	position += direction * SPEED

func _on_alive_timer_timeout():
	queue_free()
