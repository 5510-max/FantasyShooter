class_name EnemySpawner
extends Node2D

@export var spawn_radius_min: float = 300.0
@export var spawn_radius_max: float = 500.0
@export var spawn_interval: float = 2.0
@export var max_enemies: int = 50

var enemy_scene = preload("res://scenes/enemy.tscn")
var player: Node2D = null

@onready var spawn_timer: Timer = $SpawnTimer

func _ready():
	spawn_timer.wait_time = spawn_interval
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	spawn_timer.start()
	
	# 查找玩家
	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("player")

func _on_spawn_timer_timeout():
	if player == null:
		return
	
	# 检查当前敌人数量
	var current_enemies = get_tree().get_nodes_in_group("enemies").size()
	if current_enemies >= max_enemies:
		return
	
	_spawn_enemy()

func _spawn_enemy():
	# 在玩家周围的随机位置生成
	var angle = randf() * TAU
	var distance = randf_range(spawn_radius_min, spawn_radius_max)
	var spawn_pos = player.global_position + Vector2(cos(angle), sin(angle)) * distance
	
	var enemy = enemy_scene.instantiate()
	enemy.global_position = spawn_pos
	add_child(enemy)

func increase_difficulty():
	# 可以随时间增加难度：加快生成速度、增加敌人属性等
	spawn_interval = max(0.5, spawn_interval - 0.1)
	spawn_timer.wait_time = spawn_interval
