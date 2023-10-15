extends CharacterBody2D

signal player_died

var screen_middle = Vector2(DisplayServer.window_get_size()/2)

@onready var _animated_sprite = $AnimatedSprite2D

#Powers
@export var dash_boots_enabled = false
@export var machine_gun_enabled = false
@export var homing_fire_enabled = false

const glove_definitions = {
	"basic": preload("res://basic_glove.tscn"),
	"combo": preload("res://combo_glove.tscn"),
	"mega_cross": preload("res://mega_cross.tscn"),
	"mega_hook": preload("res://mega_hook.tscn"),
	"machine_gun": preload("res://machine_gun_glove.tscn"),
	"homing": preload("res://homing_glove.tscn"),
}

var gloves_in_catch_range = []

var gloves_thrown = {
	"left": null,
	"right": null,
}

var glove_on_sprite_frame = load("res://player_gloves.tres")

const SPEED = 25000.0
var combo_list = []

var dashing = false
var dashing_speed = 100000.0
var dash_frames = 0
var available_dashes = 3
@onready var dash_reset_timer = $dash_reset

var machine_gunning = false
var machine_gunning_time = 0
var last_machine_gunning_time = -999
var last_hand_thrown = "left"

var homing_firing = false
var homing_firing_time = 0
var last_homing_firing_time = -999
var homing_firing_last_hand_thrown = "left"

var rng = RandomNumberGenerator.new()

func _ready():
	_animated_sprite.sprite_frames = glove_on_sprite_frame

func _physics_process(delta):
	#update screen size
	screen_middle = Vector2(DisplayServer.window_get_size()/2)
	
	#machine gun logic
	if (machine_gunning and machine_gunning_time - last_machine_gunning_time > 0.1):
		#print("firing")
		last_hand_thrown = "right" if last_hand_thrown == "left" else "left"
		fire_glove(last_hand_thrown, get_viewport().get_mouse_position(), "machine_gun", true)
		last_machine_gunning_time = machine_gunning_time
	
	if (machine_gunning):
		machine_gunning_time += delta
		#print(machine_gunning_time)
		#print(last_machine_gunning_time)
		
		if (machine_gunning_time > 6):
			machine_gunning = false
	
	#homing fire logic
	if (homing_firing and homing_firing_time - last_homing_firing_time > 0.4):
		var random_target = Vector2(rng.randf_range(-1.0, 1.0), rng.randf_range(-1.0, 1.0)) + screen_middle
		
		#print("firing")
		homing_firing_last_hand_thrown = "right" if homing_firing_last_hand_thrown == "left" else "left"
		fire_glove(homing_firing_last_hand_thrown, random_target, "homing", true)
		last_homing_firing_time = homing_firing_time
	
	if (homing_firing):
		homing_firing_time += delta
		#print(machine_gunning_time)
		#print(last_machine_gunning_time)
		
		if (homing_firing_time > 4):
			homing_firing = false
	
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

	var move_speed = SPEED 
	
	if (dashing):
		move_speed = dashing_speed
		dash_frames += 1
		
		if (dash_frames > 6):
			dashing = false
			dash_frames = 0
			_animated_sprite.material.set("shader_parameter/white_tint", 0.0)
	
	var move_amount = move_speed * delta
	
	if direction_x != 0.0 || direction_y != 0.0:
		velocity = Vector2(direction_x, direction_y) * move_amount
		_animated_sprite.play(animation_name)
	else:
		velocity.x = move_toward(velocity.x, 0, move_amount)
		velocity.y = move_toward(velocity.y, 0, move_amount)
		_animated_sprite.stop()

	move_and_slide()

func fire_glove(glove_handedness: String, target: Vector2, forced_glove_type: String = "", forced_fire = false):
	var existing_glove = gloves_thrown[glove_handedness]
	var glove_node
	var glove_starting_position
	
	var firing_hand = find_child(glove_handedness + "_hand")
	
	#starting at 750, 500 because the character is always in middle of screen. Might need to make this dynamic to screen size?
	var target_direction = screen_middle.direction_to(target)
	
	var glove_type = "basic"
	if (forced_glove_type):
		glove_type = forced_glove_type
	elif (gloves_in_catch_range.size() > 0):
		combo_list.append(glove_handedness)
		glove_type = combo_check()
	else: 
		#missed, so reset combo
		combo_list = [glove_handedness]
	
	if (forced_fire):
		glove_starting_position = firing_hand.position
	else:
		if (!existing_glove): 
			#create and fire a new one if there isnt one yet 
			glove_starting_position = firing_hand.position
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
	glove_node.connect("area_entered", Callable(glove_node, "hit_a_bullet"))
	
	if (glove_node is Homing_Glove):
		glove_node.connect("explode", Callable(get_parent(), "create_explosion"))
	
	if (!forced_fire):
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

func hurt():
	if (!dashing):
		$hurt_sound.play()
		if ($shield_sprite.visible):
			$shield_sprite.hide()
			$shield_sprite/Timer.start()
		else:
			player_died.emit()
			queue_free()

func _on_player_glove_receipt_area_entered(glove):
	if (glove.returning):
		glove.queue_free()

func _on_catch_glove_entered(glove: Area2D):
	if (glove.returning and glove.real):
		gloves_in_catch_range.append(glove)
	
func _on_catch_glove_exited(glove: Area2D):
	if (glove.returning and glove.real):
		delete_glove_from_catch_list(glove)

func combo_check():
	#print(combo_list)
	if (combo_list.size() >= 4):
		var current_combo = combo_list.slice(combo_list.size() - 4).reduce(collect_current_combo, "")
		if (current_combo == "leftrightleftright"):
			machine_gun()
			return "combo"
			
		if (current_combo == "rightrightleftleft"):
			homing_fire()
			return "combo"
			
	if (combo_list.size() >= 3):
		var current_combo = combo_list.slice(combo_list.size() - 3).reduce(collect_current_combo, "")
		if (current_combo == "leftleftright"):
			return "mega_cross"
			
		if (current_combo == "rightleftleft"):
			return "mega_hook"
			
	return "combo"

func collect_current_combo(accum, current_string):
	return accum + current_string

func dash():
	if (dash_boots_enabled && available_dashes > 0):
		$dash_sound.play()
		dashing = true
		available_dashes -= 1
		if (!dash_reset_timer.time_left):
			dash_reset_timer.start()
		_animated_sprite.material.set("shader_parameter/white_tint", -0.2)
		
func machine_gun():
	if (machine_gun_enabled):
		machine_gunning = true
		machine_gunning_time = 0
		last_machine_gunning_time = -999
		last_hand_thrown = "left"
		
func homing_fire():
	if (homing_fire_enabled):
		homing_firing = true
		homing_firing_time = 0
		last_homing_firing_time = -999
		homing_firing_last_hand_thrown = "left"


func _on_dash_reset_timeout():
	available_dashes += 1
	
	if (available_dashes == 3):
		dash_reset_timer.stop()
