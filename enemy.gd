extends RigidBody2D

class_name Slime

signal player_hit
signal died(RigidBody2D)

@export var player: CharacterBody2D = null

@onready var HP_bar: ProgressBar = $HP_bar
@onready var nav_agent = $NavigationAgent2D

const SPEED = 70
var HP = 10
const friction = 0.1 #reduce push direction by this much
var push_direction = Vector2(0,0)
var dead = false

var move_to_player = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	HP_bar.max_value = HP
	HP_bar.value = HP
	
func init(player_target: CharacterBody2D, startingPOS: Vector2):
	player = player_target
	position = startingPOS

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	move_to_player = to_local(nav_agent.get_next_path_position()).normalized() * SPEED if (!dead) else Vector2.ZERO

#Better to interact with physics forces as it then allows the directly affected body to interact with other bodies
func _integrate_forces(state: PhysicsDirectBodyState2D):
	#var move_to_player = position.direction_to(player.position) * SPEED if (!dead) else Vector2.ZERO		
	state.linear_velocity = move_to_player + push_direction
	push_direction = push_direction * (1 - friction)

func player_body_entered(_body):
	if (!dead):
		player_hit.emit()
	
func take_damage(dmg: int):
	HP -= dmg
	HP_bar.value = HP
	
	if (HP <= 0):
		$death_timer.start()
		dead = true
		
func make_path():
	nav_agent.target_position = player.global_position

func _on_death_timer_timeout():
	died.emit(self)

func _on_nav_timer_timeout():
	make_path()
