extends Glove

@onready var combo_opportunity_sprite = $combo_sprite

func init(given_player: CharacterBody2D, given_startingPOS: Vector2, given_direction: Vector2, given_handedness: String):
	super(given_player, given_startingPOS, given_direction, given_handedness)
	
	if (handedness == "right"):
		$combo_sprite.scale.x = 1
