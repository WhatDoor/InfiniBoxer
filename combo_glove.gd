extends Glove

func init(given_player: CharacterBody2D, given_startingPOS: Vector2, given_direction: Vector2, given_type: String):
	super(given_player, given_startingPOS, given_direction, given_type)
	
	#new variables
	max_speed = 20
	ACCELERATION = 2.5
	damage = 10
	momentum = 8
	push_strength = 2700
