extends Node2D

func _draw():
	var radius = get_parent().find_child("CollisionShape2D").shape.radius
	draw_arc(Vector2.ZERO, radius, 0.0, 2*PI, 30, Color.WHITE)
