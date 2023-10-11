extends Glove

func init(given_player: CharacterBody2D, given_startingPOS: Vector2, given_direction: Vector2, given_type: String):
	super(given_player, given_startingPOS, given_direction, given_type)
	
	#new variables
	max_speed = 805
	ACCELERATION = 35.0
	damage = 10
	momentum = 1
	push_strength = 2700
