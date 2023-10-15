extends RigidBody2D

class_name Slime

signal player_hit
signal died(RigidBody2D)

@export var player: CharacterBody2D = null
@onready var HP_bar: ProgressBar = $HP_bar
@onready var nav_agent = $NavigationAgent2D

var SPEED = 70
var HP = 10
var friction = 0.1 #reduce push direction by this much
var push_direction = Vector2(0,0)
var dead = false
var spawning = true

var move_to_player = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	HP_bar.max_value = HP
	HP_bar.value = HP
	var tween = get_tree().create_tween()
	
	var saved_scale = $AnimatedSprite2D.scale
	$AnimatedSprite2D.scale = Vector2.ZERO
	tween.tween_property($AnimatedSprite2D, "scale", saved_scale, 1.0)
	tween.tween_callback(spawn_complete)

func spawn_complete():
	spawning = false
	$hurtbox.monitoring = true
	
func init(player_target: CharacterBody2D, startingPOS: Vector2):
	player = player_target
	position = startingPOS

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	move_to_player = to_local(nav_agent.get_next_path_position()).normalized() * SPEED if (!dead && !spawning) else Vector2.ZERO

#Better to interact with physics forces as it then allows the directly affected body to interact with other bodies
func _integrate_forces(state: PhysicsDirectBodyState2D):
	state.linear_velocity = move_to_player + push_direction
	push_direction = push_direction * (1 - friction)

func player_body_entered(_body):
	if (!dead):
		player_hit.emit()
	
func take_damage(dmg: int):
	$hurt_sound.play()
	HP -= dmg
	HP_bar.value = HP
	
	if (HP <= 0):
		HP_bar.hide()
		set_collision_layer_value(3, false)
		var tween = get_tree().create_tween()
		tween.tween_property($AnimatedSprite2D, "modulate", Color.LIGHT_GRAY, 0.5)
		tween.parallel().tween_property($AnimatedSprite2D, "scale", Vector2(scale.x, 0), 0.5)
		tween.tween_callback(queue_free)
		dead = true
		
func make_path():
	nav_agent.target_position = player.global_position

func _on_nav_timer_timeout():
	make_path()
