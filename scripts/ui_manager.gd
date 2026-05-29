class_name UIManager
extends CanvasLayer

# UI元素引用
@onready var health_bar: ProgressBar = $HUD/HealthBar
@onready var health_label: Label = $HUD/HealthBar/Label
@onready var exp_bar: ProgressBar = $HUD/ExpBar
@onready var exp_label: Label = $HUD/ExpBar/Label
@onready var level_label: Label = $HUD/LevelLabel
@onready var time_label: Label = $HUD/TimeLabel

@onready var level_up_message: Label = $LevelUpMessage
@onready var game_over_screen: Control = $GameOverScreen
@onready var pause_menu: Control = $PauseMenu

func _ready():
	# 隐藏不需要立即显示的元素
	level_up_message.hide()
	game_over_screen.hide()
	pause_menu.hide()

func _process(delta):
	# 更新时间显示
	if GameManager.instance and GameManager.instance.is_game_running:
		var time = int(GameManager.instance.game_time)
		var minutes = time / 60
		var seconds = time % 60
		time_label.text = "%02d:%02d" % [minutes, seconds]

func update_health(current: int, max_health: int):
	health_bar.max_value = max_health
	health_bar.value = current
	health_label.text = "%d / %d" % [current, max_health]

func update_exp(current: int, exp_to_next: int):
	exp_bar.max_value = exp_to_next
	exp_bar.value = current
	exp_label.text = "%d / %d" % [current, exp_to_next]

func update_level(level: int):
	level_label.text = "Lv.%d" % level

func show_level_up_message(level: int):
	level_up_message.text = "升级！等级 %d" % level
	level_up_message.show()
	
	# 动画效果
	var tween = create_tween()
	level_up_message.modulate = Color(1, 1, 1, 1)
	tween.tween_property(level_up_message, "scale", Vector2(1.5, 1.5), 0.3)
	tween.tween_property(level_up_message, "scale", Vector2(1, 1), 0.2)
	tween.tween_interval(1.5)
	tween.tween_property(level_up_message, "modulate", Color(1, 1, 1, 0), 0.5)
	tween.tween_callback(level_up_message.hide)

func show_game_over():
	game_over_screen.show()

func hide_game_over():
	game_over_screen.hide()

func show_pause_menu():
	pause_menu.show()

func hide_pause_menu():
	pause_menu.hide()

# 按钮回调
func _on_restart_button_pressed():
	GameManager.instance.restart_game()

func _on_resume_button_pressed():
	GameManager.instance.resume_game()

func _on_quit_button_pressed():
	get_tree().quit()
