extends Slime

var dash_direction: Vector2
var dashing = false
var current_dash_frames = 0
var dash_speed = 1000
var dash_frames = 30

func init(player_target: CharacterBody2D, startingPOS: Vector2):
	super.init(player_target, startingPOS)
	
	SPEED = 80
	
	$AttractPlayerRange.monitoring = false

func spawn_complete():
	spawning = false
	$hurtbox.monitoring = true
	$AttractPlayerRange.monitoring = true

func _integrate_forces(state: PhysicsDirectBodyState2D):
	if (!dashing):
		state.linear_velocity = move_to_player + push_direction
		push_direction = push_direction * (1 - friction)
	else:
		state.linear_velocity = dash_speed * dash_direction
		current_dash_frames += 1
		
		if (current_dash_frames > dash_frames):
			stop_dashing()

func _on_animated_sprite_2d_animation_finished():
	dash_direction = global_position.direction_to(player.global_position).normalized()
	dashing = true
	current_dash_frames = 0

func take_damage(dmg: int):
	super.take_damage(dmg)
	stop_dashing()

func stop_dashing():
	dashing = false
	SPEED = 80
	$AnimatedSprite2D.play("default")

func _on_attract_player_range_body_entered(_player):
	$AnimatedSprite2D.play("pre_attack")
	SPEED = 15
	
