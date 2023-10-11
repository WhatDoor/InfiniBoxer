extends Glove

func init(given_player: CharacterBody2D, given_startingPOS: Vector2, given_direction: Vector2, given_type: String):
	super(given_player, given_startingPOS, given_direction, given_type)
	
	#new variables
	max_speed = 800
	ACCELERATION = 85.0
	damage = 10
	momentum = 7
	push_strength = 2700
