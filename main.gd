extends Node2D

@onready var player = $player
@onready var dash_boots_item = $power_items/dash_boots
@onready var machine_gun_item = $power_items/machine_gun
@onready var homing_fire_item = $power_items/homing_fire

var enemy = preload("res://enemy.tscn")

var enemies = [
	preload("res://green_slime.tscn"),
	#preload("res://blue_slime.tscn"),
	#preload("res://black_slime.tscn"),
	#preload("res://purple_slime.tscn"),
	#preload("res://red_slime.tscn"),
]

func _ready():
	general_enemy_spawn_timer() #do first wave as game starts

func _input(event):
	# Mouse in viewport coordinates.	
	if event is InputEventMouseButton and event.is_pressed():
		if (event.button_index == MOUSE_BUTTON_LEFT):
			player.fire_glove("left",event.position)
		if (event.button_index == MOUSE_BUTTON_RIGHT):
			player.fire_glove("right", event.position)
	
	if event is InputEventKey and event.pressed:
		if (event.get_keycode() == 4194325): #shift
			player.dash()
		if (event.get_keycode() == 69): #e as test key
			player.homing_fire()

func enemy_died(dead_enemy: RigidBody2D):
	dead_enemy.queue_free()

func player_hit():
	if (!player.dashing):
		player.queue_free()
		get_tree().paused = true #Gameover

func general_enemy_spawn_timer():
	var counter = 0
	var rng = RandomNumberGenerator.new()
	while (counter < 50):
		var spawn_point = find_child("EnemySpawn" + String.num(((counter % 50) + 1)))
		var enemy_node = enemy.instantiate()
		var rand_x = ceil(rng.randf_range(-100.0, 100.0))
		var rand_y = ceil(rng.randf_range(-100.0, 100.0))
		
		enemy_node.init(player, Vector2(spawn_point.position.x + rand_x, spawn_point.position.y + rand_y))
		enemy_node.connect("player_hit", Callable(self, "player_hit"))
		enemy_node.connect("died", Callable(self, "enemy_died"))
		add_child(enemy_node)
		counter+= 1

func _on_player_player_win():
	get_tree().paused

func _on_dash_boots_body_entered(body):
	body.dash_boots_enabled = true
	dash_boots_item.collected()

func _on_machine_gun_body_entered(body):
	body.machine_gun_enabled = true
	machine_gun_item.collected()

func _on_homing_fire_body_entered(body):
	body.homing_fire_enabled = true
	homing_fire_item.collected()
