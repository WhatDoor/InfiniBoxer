extends CharacterBody2D

signal player_win

@onready var _animated_sprite = $AnimatedSprite2D

const glove_definitions = {
	"basic": preload("res://basic_glove.tscn"),
	"combo": preload("res://combo_glove.tscn"),
	"mega": preload("res://mega_cross.tscn")
}

var gloves_in_catch_range = []

var gloves_thrown = {
	"left": null,
	"right": null,
}

var glove_on_sprite_frame = load("res://player_gloves.tres")

const SPEED = 300.0
var combo_list = []

func _physics_process(delta):
	#if (Input.is_action_just_pressed("glove_toggle")):
	#	gloves_on = !gloves_on
	
	#if (gloves_on):
	_animated_sprite.sprite_frames = glove_on_sprite_frame
	#else:
	#	_animated_sprite.sprite_frames = glove_off_sprite_frame
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction_x = Input.get_axis("left", "right")
	var direction_y = Input.get_axis("up", "down")
	
	#Animation direction
	var animation_name = "run_"

	if (direction_x):
		if (direction_x > 0):
			animation_name += "right"
		else:
			animation_name += "left"

	if (direction_y):
		if (direction_y > 0):
			animation_name += "down"
		else:
			animation_name += "up"

	if direction_x != 0.0 || direction_y != 0.0:
		velocity.x = direction_x * SPEED
		velocity.y = direction_y * SPEED
		_animated_sprite.play(animation_name)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.y = move_toward(velocity.y, 0, SPEED)
		_animated_sprite.stop()

	move_and_slide()

func fire_glove(glove_handedness: String, target: Vector2):
	var existing_glove = gloves_thrown[glove_handedness]
	var glove_node
	var glove_starting_position
	
	var firing_hand = find_child(glove_handedness + "_hand")
	
	#starting at 750, 500 because the character is always in middle of screen. Might need to make this dynamic to screen size?
	var target_direction = Vector2(750, 500).direction_to(target)
	
	var glove_type = "basic"
	if (gloves_in_catch_range.size() > 0):
		combo_list.append(glove_handedness)
		glove_type = combo_check()
	else: 
		#missed, so reset combo
		combo_list = []
	
	if (!existing_glove): 
		#create and fire a new one if there isnt one yet 
		glove_starting_position = firing_hand.position + (target_direction * 15)
	else:
		#If already is one, recreate the glove at the appropriate distance	
		var glove_distance = Vector2.ZERO.distance_to(existing_glove.position)
		glove_starting_position = firing_hand.position + (target_direction * glove_distance)
		existing_glove.free()
		
	glove_node = glove_definitions[glove_type].instantiate()
	glove_node.init(self, glove_starting_position, target_direction, glove_handedness)
	glove_node.z_index = 1
	add_child(glove_node)
	glove_node.connect("body_entered", Callable(glove_node, "hit_an_enemy"))
	gloves_thrown[glove_handedness] = glove_node
		
func find_glove_with_matching_handedness(glove_handedness: String):
	for glove in gloves_in_catch_range:
		if (glove.handedness == glove_handedness):
			return glove
			
	return null

func delete_glove_from_catch_list(glove: Area2D):
	var remove_index = gloves_in_catch_range.find(glove)
	if (remove_index != -1):
		gloves_in_catch_range.remove_at(remove_index)

func _on_player_glove_receipt_area_entered(glove):
	if (glove.returning):
		glove.queue_free()

func _on_label_timeout():
	player_win.emit()

func _on_catch_glove_entered(glove: Area2D):
	if (glove.returning):
		gloves_in_catch_range.append(glove)
	
func _on_catch_glove_exited(glove: Area2D):
	if (glove.returning):
		delete_glove_from_catch_list(glove)

func combo_check():
	#print(combo_list)
	if (combo_list.size() >= 3):
		var current_combo = combo_list.slice(combo_list.size() - 3).reduce(collect_current_combo, "")
		print(current_combo)
		if (current_combo == "leftleftright"):
			return "mega"
	
	return "combo"

func collect_current_combo(accum, current_string):
	return accum + current_string
