class_name OverworldManager
extends Node2D

# 主世界管理器 - 负责场景切换、角色选择、地下城入口

# 当前选中的角色
var selected_character: String = "warrior"

# 角色数据
var characters: Dictionary = {
	"warrior": {"name": "战士", "description": "高血量近战", "unlocked": true, "cost": 0},
	"archer": {"name": "弓箭手", "description": "远程高暴击", "unlocked": false, "cost": 500},
	"mage": {"name": "法师", "description": "高伤害低血量", "unlocked": false, "cost": 1000},
	"assassin": {"name": "刺客", "description": "高移速闪避", "unlocked": false, "cost": 2000},
	"paladin": {"name": "圣骑士", "description": "均衡治疗", "unlocked": false, "cost": 5000}
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

func _ready():
	print("主世界已加载")
	_update_ui()

func _update_ui():
	# 更新金币显示
	var gold_label = get_node_or_null("CanvasLayer/GoldLabel")
	if gold_label:
		gold_label.text = "💰 %d" % player_gold

# ========== 角色选择系统 ==========
func _on_character_selected(char_id: String):
	print("点击了角色：", char_id)
	
	var char_data = characters[char_id]
	
	if char_data["unlocked"]:
		# 已解锁，直接选择
		selected_character = char_id
		print("选择角色：", char_data["name"])
		_show_dungeon_select()
	else:
		# 未解锁，尝试购买
		if player_gold >= char_data["cost"]:
			player_gold -= char_data["cost"]
			characters[char_id]["unlocked"] = true
			selected_character = char_id
			_update_ui()
			print("解锁并选择角色：", char_data["name"])
			_show_dungeon_select()
		else:
			print("金币不足！需要 ", char_data["cost"], " 金币，当前只有 ", player_gold)

# ========== 地下城选择系统 ==========
func _show_dungeon_select():
	print("显示地下城选择界面")
	
	var char_ui = get_node_or_null("CanvasLayer/CharacterSelectUI")
	var dungeon_ui = get_node_or_null("CanvasLayer/DungeonSelectUI")
	
	if char_ui:
		char_ui.hide()
	if dungeon_ui:
		dungeon_ui.show()

func _on_dungeon_selected(dungeon_id: String):
	print("点击了地下城：", dungeon_id)
	
	if not unlocked_dungeons[dungeon_id]:
		print("地下城未解锁：", dungeon_id)
		return
	
	print("进入地下城：", dungeon_id)
	print("使用角色：", characters[selected_character]["name"])
	
	# TODO: 切换到地下城场景
	# get_tree().change_scene_to_file("res://scenes/dungeons/" + dungeon_id + ".tscn")

func _on_back_to_character():
	print("返回角色选择")
	
	var char_ui = get_node_or_null("CanvasLayer/CharacterSelectUI")
	var dungeon_ui = get_node_or_null("CanvasLayer/DungeonSelectUI")
	
	if dungeon_ui:
		dungeon_ui.hide()
	if char_ui:
		char_ui.show()