class_name GameManager
extends Node

# 单例模式
static var instance: GameManager

# 游戏状态
var is_game_running: bool = false
var game_time: float = 0.0

# 玩家引用
var player: Player = null

# UI引用
@onready var ui_manager: UIManager = $UIManager

func _ready():
	instance = self
	_start_game()

func _process(delta):
	if is_game_running:
		game_time += delta

func _start_game():
	is_game_running = true
	game_time = 0.0
	
	# 查找玩家
	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("player")
	
	if player:
		# 连接玩家信号
		player.health_changed.connect(_on_player_health_changed)
		player.exp_changed.connect(_on_player_exp_changed)
		player.level_up.connect(_on_player_level_up)
		player.player_died.connect(_on_player_died)
		
		# 初始化UI
		ui_manager.update_health(player.current_health, player.max_health)
		ui_manager.update_exp(player.current_exp, player.exp_to_next_level)
		ui_manager.update_level(player.current_level)

func _on_player_health_changed(new_health, max_health):
	ui_manager.update_health(new_health, max_health)

func _on_player_exp_changed(new_exp, exp_to_next):
	ui_manager.update_exp(new_exp, exp_to_next)

func _on_player_level_up(new_level):
	ui_manager.update_level(new_level)
	ui_manager.show_level_up_message(new_level)

func _on_player_died():
	is_game_running = false
	ui_manager.show_game_over()

func pause_game():
	is_game_running = false
	get_tree().paused = true
	ui_manager.show_pause_menu()

func resume_game():
	is_game_running = true
	get_tree().paused = false
	ui_manager.hide_pause_menu()

func restart_game():
	get_tree().paused = false
	get_tree().reload_current_scene()
