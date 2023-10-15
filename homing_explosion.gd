extends Node2D

const damage = 30
const push_strength = 4000
var player_position: Vector2

func init(given_position: Vector2, given_player_position: Vector2):
	position = given_position
	player_position = given_player_position

# Called when the node enters the scene tree for the first time.
func _ready():
	$explode_sound.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func hit_an_enemy(enemy: RigidBody2D):	
	enemy.take_damage(damage)
	enemy.push_direction = player_position.direction_to(enemy.global_position) * push_strength

func _on_explode_area_body_entered(body):
	hit_an_enemy(body)

func _on_explode_collision_timer_timeout():
	$explode_area.monitoring = false

func _on_animated_sprite_2d_animation_finished():
	queue_free()
