# 全局游戏数据 - 跨场景保存数据
extends Node

# 当前选中的角色
var selected_character: String = "warrior"

# 当前地下城
var current_dungeon: String = ""

# 玩家金币
var player_gold: int = 1000

# 捕获的宠物列表
var captured_pets: Array = []

# 已解锁的地下城
var unlocked_dungeons: Dictionary = {
	"forest": true,
	"ice": false,
	"volcano": false,
	"castle": false,
	"dragon": false
}

# 角色解锁状态
var unlocked_characters: Dictionary = {
	"warrior": true,
	"archer": false,
	"mage": false,
	"assassin": false,
	"paladin": false
}

# 保存游戏
func save_game():
	var save_data = {
		"player_gold": player_gold,
		"captured_pets": captured_pets,
		"unlocked_dungeons": unlocked_dungeons,
		"unlocked_characters": unlocked_characters
	}
	
	var file = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	file.store_var(save_data)
	file.close()
	print("游戏已保存")

# 加载游戏
func load_game():
	if FileAccess.file_exists("user://savegame.save"):
		var file = FileAccess.open("user://savegame.save", FileAccess.READ)
		var save_data = file.get_var()
		file.close()
		
		player_gold = save_data.get("player_gold", 1000)
		captured_pets = save_data.get("captured_pets", [])
		unlocked_dungeons = save_data.get("unlocked_dungeons", unlocked_dungeons)
		unlocked_characters = save_data.get("unlocked_characters", unlocked_characters)
		
		print("游戏已加载")
	else:
		print("没有存档文件")

# 重置数据（新游戏）
func reset_data():
	player_gold = 1000
	captured_pets = []
	unlocked_dungeons = {
		"forest": true,
		"ice": false,
		"volcano": false,
		"castle": false,
		"dragon": false
	}
	unlocked_characters = {
		"warrior": true,
		"archer": false,
		"mage": false,
		"assassin": false,
		"paladin": false
	}
	print("数据已重置")
