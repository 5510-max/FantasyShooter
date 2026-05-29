class_name Enemy
extends CharacterBody2D

@export var max_health: int = 30
@export var move_speed: float = 80.0
@export var damage: int = 10
@export var attack_range: float = 30.0
@export var exp_value: int = 20

var current_health: int
var player: Node2D = null

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D

signal enemy_died(position, exp_value)

func _ready():
	current_health = max_health
	add_to_group("enemies")
	
	# 查找玩家
	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta):
	if player == null:
		return
	
	# 简单的追逐AI
	var direction = (player.global_position - global_position).normalized()
	var distance_to_player = global_position.distance_to(player.global_position)
	
	if distance_to_player > attack_range:
		velocity = direction * move_speed
	else:
		velocity = Vector2.ZERO
		_attack_player()
	
	move_and_slide()
	
	# 朝向玩家
	sprite.rotation = direction.angle()

func _attack_player():
	# 简单的近战攻击
	if player.has_method("take_damage"):
		player.take_damage(damage)

func take_damage(amount: int):
	current_health -= amount
	
	# 受伤闪烁
	_flash_damage()
	
	if current_health <= 0:
		_die()

func _flash_damage():
	var tween = create_tween()
	tween.tween_property(sprite, "modulate", Color(1, 0.5, 0.5), 0.1)
	tween.tween_property(sprite, "modulate", Color(1, 1, 1), 0.1)

func _die():
	enemy_died.emit(global_position, exp_value)
	
	# 掉落经验球
	_drop_exp_orb()
	
	queue_free()

func _drop_exp_orb():
	var exp_orb = preload("res://scenes/exp_orb.tscn").instantiate()
	exp_orb.global_position = global_position
	exp_orb.exp_value = exp_value
	get_tree().current_scene.add_child(exp_orb)
