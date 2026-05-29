class_name ExpOrb
extends Area2D

@export var exp_value: int = 20
@export var magnet_speed: float = 200.0
@export var magnet_range: float = 100.0

var player: Node2D = null
var is_magnetized: bool = false

@onready var sprite: Sprite2D = $Sprite2D

func _ready():
	# 查找玩家
	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("player")
	
	# 脉冲动画
	var tween = create_tween().set_loops()
	tween.tween_property(sprite, "scale", Vector2(1.2, 1.2), 0.5)
	tween.tween_property(sprite, "scale", Vector2(1.0, 1.0), 0.5)

func _physics_process(delta):
	if player == null:
		return
	
	var distance_to_player = global_position.distance_to(player.global_position)
	
	# 玩家靠近时产生磁力吸引
	if distance_to_player < magnet_range:
		is_magnetized = true
	
	if is_magnetized:
		var direction = (player.global_position - global_position).normalized()
		position += direction * magnet_speed * delta

func _on_body_entered(body):
	if body.is_in_group("player"):
		body.add_exp(exp_value)
		queue_free()
