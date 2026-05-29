class_name Player
extends CharacterBody2D

# ========== 玩家属性 ==========
@export var max_health: int = 100
@export var move_speed: float = 200.0
@export var dash_speed: float = 500.0
@export var dash_duration: float = 0.2
@export var dash_cooldown: float = 1.0
@export var fire_rate: float = 0.15  # 射击间隔（秒）

# 当前状态
var current_health: int
var current_level: int = 1
var current_exp: int = 0
var exp_to_next_level: int = 100

# 内部变量
var can_shoot: bool = true
var can_dash: bool = true
var is_dashing: bool = false
var dash_direction: Vector2 = Vector2.ZERO

# 组件引用
@onready var sprite: Sprite2D = $Sprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var shoot_timer: Timer = $ShootTimer
@onready var dash_timer: Timer = $DashTimer
@onready var dash_cooldown_timer: Timer = $DashCooldownTimer

# 信号
signal health_changed(new_health, max_health)
signal exp_changed(new_exp, exp_to_next)
signal level_up(new_level)
signal player_died

func _ready():
	current_health = max_health
	shoot_timer.wait_time = fire_rate
	shoot_timer.timeout.connect(_on_shoot_timer_timeout)
	dash_timer.wait_time = dash_duration
	dash_timer.timeout.connect(_on_dash_timer_timeout)
	dash_cooldown_timer.wait_time = dash_cooldown
	dash_cooldown_timer.timeout.connect(_on_dash_cooldown_timeout)

func _physics_process(delta):
	if is_dashing:
		velocity = dash_direction * dash_speed
	else:
		_handle_movement()
		_handle_shooting()
		_handle_dash()
	
	move_and_slide()
	_look_at_mouse()

# ========== 移动系统 ==========
func _handle_movement():
	var input_direction = Vector2.ZERO
	
	# 获取输入
	input_direction.x = Input.get_axis("move_left", "move_right")
	input_direction.y = Input.get_axis("move_up", "move_down")
	
	# 归一化防止斜向移动过快
	if input_direction != Vector2.ZERO:
		input_direction = input_direction.normalized()
	
	velocity = input_direction * move_speed

# ========== 射击系统 ==========
func _handle_shooting():
	if Input.is_action_pressed("shoot") and can_shoot:
		_shoot()

func _shoot():
	can_shoot = false
	shoot_timer.start()
	
	# 计算射击方向（朝向鼠标）
	var mouse_pos = get_global_mouse_position()
	var shoot_direction = (mouse_pos - global_position).normalized()
	
	# 创建子弹（需要在场景中预加载Bullet场景）
	var bullet = preload("res://scenes/bullet.tscn").instantiate()
	bullet.global_position = global_position + shoot_direction * 20
	bullet.direction = shoot_direction
	bullet.damage = _calculate_damage()
	get_tree().current_scene.add_child(bullet)

func _on_shoot_timer_timeout():
	can_shoot = true

# ========== 冲刺系统 ==========
func _handle_dash():
	if Input.is_action_just_pressed("dash") and can_dash and velocity != Vector2.ZERO:
		_start_dash()

func _start_dash():
	is_dashing = true
	can_dash = false
	dash_direction = velocity.normalized()
	
	# 冲刺时无敌（可选）
	collision.set_deferred("disabled", true)
	
	dash_timer.start()
	
	# 视觉反馈
	modulate = Color(1, 1, 1, 0.5)

func _on_dash_timer_timeout():
	is_dashing = false
	collision.set_deferred("disabled", false)
	modulate = Color(1, 1, 1, 1)
	dash_cooldown_timer.start()

func _on_dash_cooldown_timeout():
	can_dash = true

# ========== 视觉系统 ==========
func _look_at_mouse():
	var mouse_pos = get_global_mouse_position()
	var angle = (mouse_pos - global_position).angle()
	sprite.rotation = angle

# ========== 战斗系统 ==========
func take_damage(amount: int):
	if is_dashing:  # 冲刺时无敌
		return
	
	current_health -= amount
	health_changed.emit(current_health, max_health)
	
	# 受伤闪烁效果
	_flash_damage()
	
	if current_health <= 0:
		_die()

func _flash_damage():
	var tween = create_tween()
	tween.tween_property(sprite, "modulate", Color(1, 0, 0), 0.1)
	tween.tween_property(sprite, "modulate", Color(1, 1, 1), 0.1)

func _die():
	player_died.emit()
	queue_free()

func heal(amount: int):
	current_health = min(current_health + amount, max_health)
	health_changed.emit(current_health, max_health)

# ========== 经验/升级系统 ==========
func add_exp(amount: int):
	current_exp += amount
	
	while current_exp >= exp_to_next_level:
		current_exp -= exp_to_next_level
		_level_up()
	
	exp_changed.emit(current_exp, exp_to_next_level)

func _level_up():
	current_level += 1
	exp_to_next_level = int(exp_to_next_level * 1.5)  # 每级所需经验增加50%
	
	# 升级奖励
	max_health += 10
	current_health = max_health
	
	level_up.emit(current_level)
	print("升级了！当前等级：", current_level)

func _calculate_damage() -> int:
	# 基础伤害 + 等级加成
	return 10 + (current_level - 1) * 2
