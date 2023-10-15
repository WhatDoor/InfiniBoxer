extends Slime

func init(player_target: CharacterBody2D, startingPOS: Vector2):
	super.init(player_target, startingPOS)

	HP = 100
	friction = 0.5
