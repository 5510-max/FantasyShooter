class_name OverworldManager
extends Node2D

# 主世界管理器 - 负责场景切换、角色选择、地下城入口

@export var dungeon_scenes: Dictionary = {
	"forest": "res://scenes/dungeons/forest_cave.tscn",
	"ice": "res://scenes/dungeons/ice_cave.tscn",
	"volcano": "res://scenes/dungeons/volcano_cave.tscn",
	"castle": "res://scenes/dungeons/ghost_castle.tscn",
	"dragon": "res://scenes/dungeons/dragon_lair.tscn"
}

# 当前选中的角色
var selected_character: String = "warrior"

# 角色数据
var characters: Dictionary = {
	"warrior": {
		"name": "战士",
		"description": "高血量近战",
		"unlocked": true,
		"cost": 0,
		"color": Color(0.8, 0.2, 0.2)
	},
	"archer": {
		"name": "弓箭手",
		"description": "远程高暴击",
		"unlocked": false,
		"cost": 500,
		"color": Color(0.2, 0.8, 0.2)
	},
	"mage": {
		"name": "法师",
		"description": "高伤害低血量",
		"unlocked": false,
		"cost": 1000,
		"color": Color(0.2, 0.2, 0.8)
	},
	"assassin": {
		"name": "刺客",
		"description": "高移速闪避",
		"unlocked": false,
		"cost": 2000,
		"color": Color(0.5, 0.2, 0.5)
	},
	"paladin": {
		"name": "圣骑士",
		"description": "均衡治疗",
		"unlocked": false,
		"cost": 5000,
		"color": Color(0.9, 0.7, 0.2)
	}
}

# 地下城解锁状态
var unlocked_dungeons: Dictionary = {
	"forest": true,
	"ice": false,
	"volcano": false,
	"castle": false,
	"dragon": false
}

# 玩家金币
var player_gold: int = 1000

# UI引用
@onready var character_select_ui: Control = $CanvasLayer/CharacterSelectUI
@onready var dungeon_select_ui: Control = $CanvasLayer/DungeonSelectUI
@onready var gold_label: Label = $CanvasLayer/GoldLabel

func _ready():
	_update_gold_display()
	_show_character_select()

func _update_gold_display():
	gold_label.text = "💰 %d" % player_gold

# ========== 角色选择系统 ==========
func _show_character_select():
	character_select_ui.show()
	dungeon_select_ui.hide()
	_update_character_buttons()

func _update_character_buttons():
	# 更新角色选择按钮状态
	for char_id in characters.keys():
		var btn = character_select_ui.get_node_or_null("Panel/CharacterGrid/%sButton" % char_id)
		if btn:
			var char_data = characters[char_id]
			if char_data.unlocked:
				btn.text = "%s\n%s" % [char_data.name, char_data.description]
				btn.modulate = Color(1, 1, 1)
			else:
				btn.text = "%s\n💰 %d" % [char_data.name, char_data.cost]
				btn.modulate = Color(0.5, 0.5, 0.5)

func _on_character_selected(char_id: String):
	var char_data = characters[char_id]
	
	if char_data.unlocked:
		# 已解锁，直接选择
		selected_character = char_id
		print("选择角色：", char_data.name)
		_show_dungeon_select()
	else:
		# 未解锁，尝试购买
		if player_gold >= char_data.cost:
			player_gold -= char_data.cost
			characters[char_id].unlocked = true
			selected_character = char_id
			_update_gold_display()
			_update_character_buttons()
			print("解锁并选择角色：", char_data.name)
			_show_dungeon_select()
		else:
			print("金币不足！")

# ========== 地下城选择系统 ==========
func _show_dungeon_select():
	character_select_ui.hide()
	dungeon_select_ui.show()
	_update_dungeon_buttons()

func _update_dungeon_buttons():
	for dungeon_id in unlocked_dungeons.keys():
		var btn = dungeon_select_ui.get_node_or_null("Panel/DungeonGrid/%sButton" % dungeon_id)
		if btn:
			if unlocked_dungeons[dungeon_id]:
				btn.modulate = Color(1, 1, 1)
				btn.disabled = false
			else:
				btn.modulate = Color(0.3, 0.3, 0.3)
				btn.disabled = true

func _on_dungeon_selected(dungeon_id: String):
	if not unlocked_dungeons[dungeon_id]:
		return
	
	print("进入地下城：", dungeon_id)
	print("使用角色：", characters[selected_character].name)
	
	# 切换到地下城场景
	var scene_path = dungeon_scenes.get(dungeon_id, "")
	if scene_path != "":
		# 保存当前数据
		GameData.selected_character = selected_character
		GameData.current_dungeon = dungeon_id
		
		# 切换场景
		get_tree().change_scene_to_file(scene_path)

func _on_back_to_character():
	_show_character_select()

# ========== 解锁地下城 ==========
func unlock_dungeon(dungeon_id: String):
	if unlocked_dungeons.has(dungeon_id):
		unlocked_dungeons[dungeon_id] = true
		print("解锁地下城：", dungeon_id)
