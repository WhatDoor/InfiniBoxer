extends Node2D

@onready var player = $player
@onready var dash_boots_item = $power_items/dash_boots
@onready var machine_gun_item = $power_items/machine_gun
@onready var homing_fire_item = $power_items/homing_fire

var enemy = preload("res://green_slime.tscn")
var slime_bullet = preload("res://slime_bullet.tscn")
var homing_explosion = preload("res://homing_explosion.tscn")

var enemies = {
	"green": preload("res://green_slime.tscn"),
	"blue": preload("res://blue_slime.tscn"),
	"black": preload("res://black_slime.tscn"),
	"purple": preload("res://purple_slime.tscn"),
	"red": preload("res://red_slime.tscn"),
}

@onready var tilemap = $TileMap

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
		#print(event.get_keycode())
		if (event.get_keycode() == 32): #space bar
			player.dash()
		#if (event.get_keycode() == 69): #e as test key
		#	player.homing_fire()

func enemy_died(dead_enemy: RigidBody2D):
	dead_enemy.queue_free()

func player_hit(_body=""):
	player.hurt()
		
var green_slime_prop = 50
var blue_slime_prop = 0
var red_slime_prop = 0
var black_slime_prop = 0
var purple_slime_prop = 0
var seconds = 0

func tick_slime_props():
	green_slime_prop -= 1
	green_slime_prop = clamp(green_slime_prop, 0, 100)
	
	blue_slime_prop += 0.5
	blue_slime_prop = clamp(blue_slime_prop, 0, 50)
	
	red_slime_prop += 0.05
	black_slime_prop += 0.05
	purple_slime_prop += 0.05
	
func calculate_enemy_proportions():
	var sum = float(green_slime_prop + blue_slime_prop + red_slime_prop + black_slime_prop + purple_slime_prop)
	
	var proportions = {
		"green": green_slime_prop/sum,
		"blue": blue_slime_prop/sum,
		"red": red_slime_prop/sum,
		"black": black_slime_prop/sum,
		"purple": purple_slime_prop/sum
	}
	
	return proportions

func pick_enemy():
	var proportions = calculate_enemy_proportions()
	#print(proportions)
	
	var rng = RandomNumberGenerator.new()
	var rand_num = rng.randf()
	#print(rand_num)
	
	var current_sum = 0
	for key in proportions.keys():
		current_sum += proportions[key]
		
		if (rand_num <= current_sum):
			#print(key)
			return key

var number_of_enemies = 10
var enemy_acceleration = 0
func general_enemy_spawn_timer():
	var counter = 0
	var _proportions = calculate_enemy_proportions()
	
	var enemy_counter = {
		"green": 0,
		"blue": 0,
		"red": 0,
		"black": 0,
		"purple": 0
	}
	
	while (counter < number_of_enemies):		
		var spawn_point = find_child("EnemySpawn" + String.num(((counter % 50) + 1)))
		
		var enemy_type = pick_enemy()
		enemy_counter[enemy_type] += 1
	
		var enemy_node = enemies[enemy_type].instantiate()
		enemy_node.init(player, Vector2(spawn_point.position.x, spawn_point.position.y))
		enemy_node.connect("player_hit", Callable(self, "player_hit"))
		enemy_node.connect("died", Callable(self, "enemy_died"))
		if (enemy_type == "purple"):
			enemy_node.connect("fire_slime", Callable(self, "fire_slime_bullet"))
		add_child(enemy_node)
		counter+= 1
	
	tick_slime_props()
	#exponentially increase the number of enemies being spawned in over time
	enemy_acceleration += 0.05
	number_of_enemies += floor(enemy_acceleration)
	
	#general spawner debug
	print("Seconds: " + str(seconds))
	print(number_of_enemies)
	#print(proportions)
	print(enemy_counter)
	
	seconds += 10
	#if (seconds == 900):
	#	get_tree().paused = true

func spawn_enemy(enemy_type, given_position, group=""):
	var enemy_node = enemies[enemy_type].instantiate()
	enemy_node.init(player, given_position)
	enemy_node.connect("player_hit", Callable(self, "player_hit"))
	enemy_node.connect("died", Callable(self, "enemy_died"))
	if (enemy_type == "purple"):
		enemy_node.connect("fire_slime", Callable(self, "fire_slime_bullet"))
	if (group != ""):
		enemy_node.add_to_group(group)
	call_deferred("add_child", enemy_node)

func _on_player_player_win():
	get_tree().paused = true

func _on_dash_boots_body_entered(body):
	body.dash_boots_enabled = true
	dash_boots_item.collected()

func _on_machine_gun_body_entered(body):
	body.machine_gun_enabled = true
	machine_gun_item.collected()

func _on_homing_fire_body_entered(body):
	body.homing_fire_enabled = true
	homing_fire_item.collected()

func fire_slime_bullet(given_position: Vector2, given_direction: Vector2):
	var slime_bullet_node = slime_bullet.instantiate()
	slime_bullet_node.init(given_position, given_direction)
	slime_bullet_node.connect("body_entered", Callable(self, "player_hit"))
	add_child(slime_bullet_node)
	
func create_explosion(given_position: Vector2, player_position: Vector2):
	var homing_explosion_node = homing_explosion.instantiate()
	homing_explosion_node.init(given_position, player_position)
	add_child(homing_explosion_node)

func _on_forest_area_1_body_entered(_body):
	$EnemiesTriggeredSound.play()
	var spawn_points = $forest_region/Area1/spawn_areas.get_children()
	var area = $forest_region/Area1
	area.set_deferred("monitoring", false)
	
	for spawn_point in spawn_points:
		spawn_enemy("black", spawn_point.global_position)
		
func _on_forest_area_2_body_entered(_body):
	$EnemiesTriggeredSound.play()
	var spawn_points = $forest_region/Area2/spawn_areas.get_children()
	var area = $forest_region/Area2
	area.set_deferred("monitoring", false)
	
	for spawn_point in spawn_points:
		spawn_enemy("black", spawn_point.global_position)

func _on_forest_area_3_body_entered(_body):
	$EnemiesTriggeredSound.play()
	var spawn_points = $forest_region/Area3/spawn_areas.get_children()
	var area = $forest_region/Area3
	area.set_deferred("monitoring", false)
	
	for spawn_point in spawn_points:
		spawn_enemy("black", spawn_point.global_position)

var forest_area_4_counter = 0
@onready var forest_area_4_spawn_points = $forest_region/Area4/spawn_areas.get_children()
@onready var forest_area_4_timer = $forest_region/area4_timer
func _on_forest_area_4_body_entered(_body):
	$EnemiesTriggeredSound.play()
	var area = $forest_region/Area4
	area.set_deferred("monitoring", false)
	forest_area_4_timer.start()

func _on_forest_area_4_timer_timeout():
	spawn_enemy("black", forest_area_4_spawn_points[forest_area_4_counter].global_position)
	forest_area_4_counter += 1
	
	if (forest_area_4_counter < forest_area_4_spawn_points.size()):
		forest_area_4_timer.start()

@onready var desert_blue_spawns = $desert_region/blue_spawn_points.get_children()
@onready var blue_spawn_timer = $desert_region/blue_spawn_timer
@onready var desert_check_timer = $desert_region/check_timer
func _on_desert_area_2d_body_entered(_body):
	$EnemiesTriggeredSound.play()
	var red_spawns = $desert_region/red_spawn_points.get_children()
	
	tilemap.set_layer_enabled(4, true)
	
	var area = $desert_region/Area2D
	area.set_deferred("monitoring", false)
	
	for spawn_point in red_spawns:
		spawn_enemy("red", spawn_point.global_position, "desert_red_slime")
		
	for spawn_point in desert_blue_spawns:
		spawn_enemy("blue", spawn_point.global_position)
	
	blue_spawn_timer.start()
	desert_check_timer.start()

func _on_desert_blue_spawn_timer_timeout():
	for spawn_point in desert_blue_spawns:
		spawn_enemy("blue", spawn_point.global_position)

func _on_check_timer_timeout():
	var desert_red_slimes = get_tree().get_nodes_in_group("desert_red_slime")
	
	if (desert_red_slimes.size() == 0):
		tilemap.set_layer_enabled(4, false)
		blue_spawn_timer.stop()
		desert_check_timer.stop()

func _on_water_area_1_body_entered(_body):
	$EnemiesTriggeredSound.play()
	var purple_spawns = $water_region/Area1/purple_spawn_points.get_children()
	
	var area = $water_region/Area1
	area.set_deferred("monitoring", false)
	
	for spawn_point in purple_spawns:
		spawn_enemy("purple", spawn_point.global_position)

func _on_water_area_2_body_entered(_body):
	$EnemiesTriggeredSound.play()
	var blue_spawns = $water_region/Area2/blue_spawn_points.get_children()
	var purple_spawns = $water_region/Area2/purple_spawn_points.get_children()
	
	var area = $water_region/Area2
	area.set_deferred("monitoring", false)
	
	for spawn_point in blue_spawns:
		spawn_enemy("blue", spawn_point.global_position)
		
	for spawn_point in purple_spawns:
		spawn_enemy("purple", spawn_point.global_position)


func _on_water_area_3_body_entered(_body):
	$EnemiesTriggeredSound.play()
	var purple_spawns = $water_region/Area3/purple_spawn_points.get_children()
	
	var area = $water_region/Area3
	area.set_deferred("monitoring", false)
	
	for spawn_point in purple_spawns:
		spawn_enemy("purple", spawn_point.global_position)


func _on_water_area_4_body_entered(_body):
	$EnemiesTriggeredSound.play()
	var blue_spawns = $water_region/Area4/blue_spawn_points.get_children()
	var purple_spawns = $water_region/Area4/purple_spawn_points.get_children()
	
	var area = $water_region/Area4
	area.set_deferred("monitoring", false)
	
	for spawn_point in blue_spawns:
		spawn_enemy("blue", spawn_point.global_position)
		
	for spawn_point in purple_spawns:
		spawn_enemy("purple", spawn_point.global_position)


func _on_water_area_lock_body_entered(_body):
	if (player.homing_fire_enabled):
		tilemap.set_layer_enabled(5, true)

func _on_player_player_died():
	$PlayUI.hide()
	$EndScreen.set_score($PlayUI/Label.counter)
	$EndScreen.show()
	get_tree().paused = true
