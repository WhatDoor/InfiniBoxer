extends Area2D

class_name Glove

var default_sprite: Sprite2D

var player: CharacterBody2D
var direction: Vector2
var handedness: String
var real = true

var speed = 0.0
var max_speed = 620.0
var ACCELERATION = 45.0

var returning = false
var return_speed = 0.0
var return_acceleration = 4.0

var max_range = 70.0
var damage = 5
var momentum = 4
var push_strength = 1700

var enemy_ignore_list = []

# Called when the node enters the scene tree for the first time.
func _ready():
	$Fire_Sound.play()

func init(given_player: CharacterBody2D, given_startingPOS: Vector2, given_direction: Vector2, given_handedness: String):
	player = given_player
	position = given_startingPOS
	direction = given_direction
	handedness = given_handedness
	rotation = Vector2(0, -1).angle_to(given_direction) #start from 0,1 to offset for the fact the startings pointing up by default
	
	#flip the sprite for the other hand
	if (handedness == "right"):
		$default_sprite.scale.x = 1
	
	apply_scale(Vector2(0.5, 0.5))
	
	#Need to call these manually here instead of onready because onready is used when it enters the tree
	#In this case, the children of these will inherit and first be created separately from the tree
	#raycasts = [$RayCast2D, $RayCast2D2, $RayCast2D3]
	default_sprite = $default_sprite

func _physics_process(delta):
	#If the glove runs out of momentum OR reaches its max range
	if (Vector2.ZERO.distance_to(position) > max_range || momentum <= 0):
		returning = true
		set_collision_mask_value(3, false) #no longer detect enemies on the way back

	if (returning):
		#print(speed)
		return_speed += return_acceleration

		var return_position = player.find_child(handedness + "_hand").position
		position = position.move_toward(return_position, return_speed * delta)
		#position = Vector2(position.x + (player.position.x * return_speed), position.y + (player.position.y * return_speed))
	else:
		speed += ACCELERATION
		var relative_attempted_position = Vector2(position.x + (direction.x * speed * delta), position.y + (direction.y * speed * delta))
		
		position = relative_attempted_position
		
		
func hit_an_enemy(enemy: RigidBody2D):
	var ignored_enemy_id = enemy_ignore_list.find(enemy.get_instance_id())
	
	if (ignored_enemy_id == -1 && !enemy.dead):
		momentum -= 1
		enemy.take_damage(calculate_damage())
		enemy.push_direction = get_parent().global_position.direction_to(enemy.position) * push_strength
		enemy_ignore_list.append(enemy.get_instance_id())

func hit_a_bullet(bullet: Area2D):
	bullet.queue_free()

func calculate_damage():
	#The closer we are to max speed, the more damage we deal
	var scaling = speed/max_speed
	return floor(damage * scaling)
