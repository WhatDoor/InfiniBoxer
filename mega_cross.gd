extends Glove

func init(given_player: CharacterBody2D, given_startingPOS: Vector2, given_direction: Vector2, given_type: String):
	super(given_player, given_startingPOS, given_direction, given_type)
	
	#new variables
	max_speed = 20
	ACCELERATION = 35.0
	damage = 10
	push_strength = 2700
	momentum = 50
	
	return_acceleration = 2.0

func calculate_damage():
	return damage
