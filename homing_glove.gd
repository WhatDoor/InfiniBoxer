extends Glove

class_name Homing_Glove

signal explode(position: Vector2, player_position: Vector2)

var alive_time = 0
var locked_enemy: RigidBody2D = null

func init(given_player: CharacterBody2D, given_startingPOS: Vector2, given_direction: Vector2, given_handedness: String):
	super(given_player, given_startingPOS, given_direction, given_handedness)
	
	#new variables
	real = false
	
	#new variables
	max_speed = 805
	ACCELERATION = 6.0
	damage = 30
	momentum = 1
	push_strength = 1000
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	#If the glove runs out of momentum OR reaches its max range
	if (alive_time > 2000 || momentum <= 0):
		explode.emit(global_position, get_parent().global_position)
		queue_free()
		
	if (!locked_enemy):
		speed += ACCELERATION
		var relative_attempted_position = Vector2(position.x + (direction.x * speed * delta), position.y + (direction.y * speed * delta))
		position = relative_attempted_position
	else:
		speed += ACCELERATION
		var direction_to_enemy = global_position.direction_to(locked_enemy.position)
		var relative_attempted_position = Vector2(position.x + (direction_to_enemy.x * speed * delta), position.y + (direction_to_enemy.y * speed * delta))
		look_at(locked_enemy.position)
		rotate(PI/2)
		position = relative_attempted_position
	
	alive_time += delta

func calculate_damage():
	return damage

func _on_detector_body_entered(enemy):
	#lock onto an enemy
	locked_enemy = enemy
	ACCELERATION = 40
	$Detector.set_deferred("monitoring", false)
