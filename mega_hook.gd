extends Glove

var radius = 40
var starting_angle
var spin_angle
const max_spin_angle = PI*3/5

func init(given_player: CharacterBody2D, given_startingPOS: Vector2, given_direction: Vector2, given_handedness: String):
	super(given_player, given_startingPOS, given_direction, given_handedness)
	
	#new variables
	max_speed = 20
	ACCELERATION = 1.0
	damage = 10
	push_strength = 2700
	momentum = 50
	max_range = 5
	
	if (given_handedness == "left"):
		starting_angle = given_direction.angle() - PI/2
	elif (given_handedness == "right"):
		starting_angle = given_direction.angle() + PI/2
	
	spin_angle = starting_angle
	
	return_acceleration = 2.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var current_spin_angle_amount = abs(starting_angle - spin_angle)
	
	#If the glove runs out of momentum OR reaches its max range
	if (current_spin_angle_amount > max_spin_angle || momentum <= 0):
		returning = true
		set_collision_mask_value(3, false) #no longer detect enemies on the way back

	if (returning):
		return_speed += return_acceleration * delta

		var return_position = player.find_child(handedness + "_hand").position
		position = position.move_toward(return_position, return_speed)
	else:
		speed += ACCELERATION * delta
		
		if (handedness == "left"):
			spin_angle += speed
			#var fist_rotation_scaling = current_spin_angle_amount/(max_spin_angle-PI/9)
			#rotation = fist_rotation_scaling * PI/2 - starting_angle
			look_at(player.position)
		elif (handedness == "right"):
			spin_angle -= speed
			#var fist_rotation_scaling = current_spin_angle_amount/(max_spin_angle-PI/9)
			#rotation = fist_rotation_scaling * -PI/2 + starting_angle
			look_at(player.position)
			rotate(PI)

		var offset = Vector2(cos(spin_angle), sin(spin_angle)) * radius;
		position = offset
		

func calculate_damage():
	return damage
