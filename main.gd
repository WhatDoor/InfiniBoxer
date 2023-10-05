extends Node

@onready var player = $player

var enemy = preload("res://enemy.tscn")

func _ready():
	general_enemy_spawn_timer() #do first wave as game starts

func _input(event):
	# Mouse in viewport coordinates.	
	if event is InputEventMouseButton and event.is_pressed():
		if (event.button_index == MOUSE_BUTTON_LEFT):
			player.fire_glove("left", event.position)
		if (event.button_index == MOUSE_BUTTON_RIGHT):
			player.fire_glove("right", event.position)

func enemy_died(dead_enemy: RigidBody2D):
	dead_enemy.queue_free()

func player_hit():
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
