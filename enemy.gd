extends RigidBody2D

signal player_hit
signal died(RigidBody2D)

@export var player: CharacterBody2D = null

@onready var HP_bar: ProgressBar = $HP_bar

const SPEED = 70
var HP = 10
const friction = 0.1 #reduce push direction by this much
var push_direction = Vector2(0,0)
var dead = false

# Called when the node enters the scene tree for the first time.
func _ready():
	HP_bar.max_value = HP
	HP_bar.value = HP
	
func init(player_target: CharacterBody2D, startingPOS: Vector2):
	player = player_target
	position = startingPOS

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

#Better to interact with physics forces as it then allows the directly affected body to interact with other bodies
func _integrate_forces(state: PhysicsDirectBodyState2D):
	var move_to_player = position.direction_to(player.position) * SPEED if (!dead) else Vector2.ZERO		
	
	
	state.linear_velocity = move_to_player + push_direction
	push_direction = push_direction * (1 - friction)

func player_body_entered(body):
	if (!dead):
		player_hit.emit()
	
func take_damage(dmg: int):
	HP -= dmg
	HP_bar.value = HP
	
	if (HP <= 0):
		$death_timer.start()
		dead = true

func _on_death_timer_timeout():
	died.emit(self)
