class_name Bullet
extends Area2D

@export var speed: float = 600.0
@export var lifetime: float = 2.0

var direction: Vector2 = Vector2.RIGHT
var damage: int = 10

@onready var sprite: Sprite2D = $Sprite2D

func _ready():
	# 设置旋转朝向飞行方向
	rotation = direction.angle()
	
	# 生命周期结束后自动销毁
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _physics_process(delta):
	position += direction * speed * delta

func _on_body_entered(body):
	# 击中敌人
	if body.is_in_group("enemies"):
		body.take_damage(damage)
		_create_hit_effect()
		queue_free()
	
	# 击中墙壁
	elif body.is_in_group("walls"):
		_create_hit_effect()
		queue_free()

func _create_hit_effect():
	# 可以在这里实例化粒子效果
	pass
