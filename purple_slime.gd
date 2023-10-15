extends Slime

signal fire_slime(position: Vector2, direction: Vector2)
var can_shoot = true

func init(player_target: CharacterBody2D, startingPOS: Vector2):
	super.init(player_target, startingPOS)
	
	$AttractPlayerRange.monitoring = false
	
func _physics_process(_delta):
	var distance_to_player = global_position.distance_to(player.global_position)
	
	if (distance_to_player < $AttractPlayerRange/CollisionShape2D.shape.radius):
		move_to_player = global_position.direction_to(player.global_position).normalized() * -1 * SPEED if (!dead && !spawning) else Vector2.ZERO
	else:
		move_to_player = to_local(nav_agent.get_next_path_position()).normalized() * SPEED if (!dead && !spawning) else Vector2.ZERO

func spawn_complete():
	spawning = false
	$hurtbox.monitoring = true
	$AttractPlayerRange.monitoring = true

func shoot():
	fire_slime.emit(global_position, global_position.direction_to(player.global_position))
	can_shoot = false
	$AnimatedSprite2D.play("default")
	SPEED = 70

func _on_attract_player_range_body_entered(_body):
	if (can_shoot):
		$AnimatedSprite2D.play("pre_attack")
		SPEED = 0
	
func _on_animated_sprite_2d_animation_finished():
	shoot()

func _on_shoot_timer_timeout():
	can_shoot = true
