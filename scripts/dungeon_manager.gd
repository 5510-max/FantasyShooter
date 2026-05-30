class_name DungeonManager
extends Node2D

# 地下城管理器 - 负责地下城内的游戏逻辑

@export var dungeon_type: String = "forest"  # forest, ice, volcano, castle, dragon
@export var dungeon_name: String = "蝙蝠洞穴"
@export var dungeon_difficulty: int = 2  # 1-6星难度

# 地下城状态
var is_active: bool = false
var enemies_killed: int = 0
var total_enemies: int = 0
var boss_spawned: bool = false
var boss_killed: bool = false

# 玩家引用
var player: Node2D = null

# 宠物引用
var active_pet: Node2D = null

# 组件引用
@onready var enemy_spawner: Node2D = $EnemySpawner
@onready var exit_portal: Area2D = $ExitPortal
@onready var dungeon_timer: Timer = $DungeonTimer

# 信号
signal dungeon_completed(dungeon_type, enemies_killed)
signal dungeon_failed()
signal boss_spawned_signal()
signal pet_found(pet_type)

func _ready():
	_apply_dungeon_style()
	_setup_dungeon()
	
	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("player")
	
	if player:
		# 连接玩家死亡信号
		if player.has_signal("player_died"):
			player.player_died.connect(_on_player_died)

func _apply_dungeon_style():
	# 根据地下城类型应用不同的视觉效果
	var shader_material = ShaderMaterial.new()
	
	match dungeon_type:
		"forest":
			# 清新卡通风格 - 默认，不需要shader
			modulate = Color(1, 1, 1)
		"ice":
			# 像素风格
			var pixel_shader = preload("res://shaders/pixel_style.gdshader")
			if pixel_shader:
				shader_material.shader = pixel_shader
				$Background.material = shader_material
			modulate = Color(0.8, 0.9, 1.0)
		"volcano":
			# 水墨风格
			var ink_shader = preload("res://shaders/ink_style.gdshader")
			if ink_shader:
				shader_material.shader = ink_shader
				$Background.material = shader_material
			modulate = Color(1.0, 0.8, 0.7)
		"castle":
			# 剪影风格
			var silhouette_shader = preload("res://shaders/silhouette_style.gdshader")
			if silhouette_shader:
				shader_material.shader = silhouette_shader
				$Background.material = shader_material
			modulate = Color(0.6, 0.5, 0.7)
		"dragon":
			# 油画风格
			var oil_shader = preload("res://shaders/oil_style.gdshader")
			if oil_shader:
				shader_material.shader = oil_shader
				$Background.material = shader_material
			modulate = Color(1.0, 0.95, 0.8)

func _setup_dungeon():
	# 设置地下城参数
	match dungeon_type:
		"forest":
			dungeon_name = "蝙蝠洞穴"
			dungeon_difficulty = 2
			total_enemies = 30
		"ice":
			dungeon_name = "冰雪洞窟"
			dungeon_difficulty = 3
			total_enemies = 40
		"volcano":
			dungeon_name = "火山熔岩洞"
			dungeon_difficulty = 4
			total_enemies = 50
		"castle":
			dungeon_name = "幽灵城堡"
			dungeon_difficulty = 5
			total_enemies = 60
		"dragon":
			dungeon_name = "龙穴"
			dungeon_difficulty = 6
			total_enemies = 70
	
	is_active = true

func _process(delta):
	if not is_active:
		return
	
	# 检查是否该生成Boss
	if enemies_killed >= total_enemies and not boss_spawned:
		_spawn_boss()
	
	# 检查是否完成地下城
	if boss_killed:
		_complete_dungeon()

func _spawn_boss():
	boss_spawned = true
	boss_spawned_signal.emit()
	
	# 创建Boss
	var boss_scene = preload("res://scenes/boss.tscn")
	if boss_scene:
		var boss = boss_scene.instantiate()
		boss.dungeon_type = dungeon_type
		boss.global_position = _get_boss_spawn_position()
		add_child(boss)
		
		# 连接Boss死亡信号
		if boss.has_signal("boss_died"):
			boss.boss_died.connect(_on_boss_died)

func _get_boss_spawn_position() -> Vector2:
	return Vector2(640, 200)

func _on_boss_died():
	boss_killed = true
	enemies_killed += 10

func _complete_dungeon():
	is_active = false
	dungeon_completed.emit(dungeon_type, enemies_killed)
	
	# 显示出口传送门
	if exit_portal:
		exit_portal.show()
	
	# 解锁下一个地下城
	_unlock_next_dungeon()

func _unlock_next_dungeon():
	var unlock_order = ["forest", "ice", "volcano", "castle", "dragon"]
	var current_index = unlock_order.find(dungeon_type)
	
	if current_index >= 0 and current_index < unlock_order.size() - 1:
		var next_dungeon = unlock_order[current_index + 1]
		GameData.unlocked_dungeons[next_dungeon] = true
		GameData.save_game()

func _on_player_died():
	is_active = false
	dungeon_failed.emit()

func _on_enemy_killed():
	enemies_killed += 1
	
	# 随机掉落经验球
	if randf() < 0.3:
		_spawn_exp_orb()
	
	# 随机发现宠物
	if randf() < 0.05:  # 5%概率
		_spawn_pet()

func _spawn_exp_orb():
	var exp_orb_scene = preload("res://scenes/exp_orb.tscn")
	if exp_orb_scene:
		var exp_orb = exp_orb_scene.instantiate()
		exp_orb.global_position = _get_random_position()
		add_child(exp_orb)

func _spawn_pet():
	# 根据地下城类型生成对应宠物
	var pet_types = {
		"forest": "wolf",
		"ice": "ice_crystal",
		"volcano": "fire_lizard",
		"castle": "skeleton",
		"dragon": "baby_dragon"
	}
	
	var pet_type = pet_types.get(dungeon_type, "wolf")
	pet_found.emit(pet_type)
	
	# 创建可捕获的宠物
	var pet_scene = preload("res://scenes/capturable_pet.tscn")
	if pet_scene:
		var pet = pet_scene.instantiate()
		pet.pet_type = pet_type
		pet.global_position = _get_random_position()
		add_child(pet)

func _get_random_position() -> Vector2:
	return Vector2(randf_range(100, 1180), randf_range(100, 620))

func _on_exit_portal_body_entered(body):
	if body.is_in_group("player"):
		# 返回主世界
		get_tree().change_scene_to_file("res://scenes/overworld.tscn")

func spawn_sprite(sprite_type: String, position: Vector2):
	# 生成精灵
	var sprite_scene = preload("res://scenes/sprite.tscn")
	if sprite_scene:
		var sprite = sprite_scene.instantiate()
		sprite.sprite_type = sprite_type
		sprite.global_position = position
		add_child(sprite)