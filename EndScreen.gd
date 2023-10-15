extends CanvasLayer

func set_score(score):
	$Label2.text = "You survived for " + str(score) + " seconds."
