extends Glove


func init(given_player: CharacterBody2D, given_startingPOS: Vector2, given_direction: Vector2, given_handedness: String):
	super(given_player, given_startingPOS, given_direction, given_handedness)
	
	#new variables
	real = false
	
	#new variables
	max_speed = 805
	ACCELERATION = 100.0
	damage = 30
	momentum = 3
	push_strength = 7000
	max_range = 100
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	#If the glove runs out of momentum OR reaches its max range
	if (Vector2.ZERO.distance_to(position) > max_range || momentum <= 0):
		queue_free()

	speed += ACCELERATION
	var relative_attempted_position = Vector2(position.x + (direction.x * speed * delta), position.y + (direction.y * speed * delta))
	
	position = relative_attempted_position

func calculate_damage():
	return damage
