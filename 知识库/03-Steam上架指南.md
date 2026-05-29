# Steam上架完整指南

## 1. 准备工作

### 注册Steam开发者
1. 访问 https://partner.steamgames.com/
2. 注册Steam开发者账号
3. 支付 **100美元** 上架费（一次性，每个游戏）
4. 完成税务和银行信息

### 准备素材
| 素材 | 尺寸 | 用途 |
|------|------|------|
| 胶囊图（主图） | 460×215 | 商店页面主图 |
| 小胶囊图 | 231×87 | 列表显示 |
| 大胶囊图 | 616×353 | 特色展示 |
| 主视觉图 | 1920×1080 | 页面顶部 |
| 截图 | 1920×1080 | 至少5张 |
| 视频/预告片 | 1920×1080 | 推荐30-60秒 |

## 2. 游戏打包

### Godot导出设置
1. 点击 **项目 → 导出**
2. 添加 **Windows Desktop** 预设
3. 配置：
   - 可执行文件名称：`FantasyShooter.exe`
   - 导出路径：`C:/Builds/FantasyShooter/`
   - 勾选 **导出选中的场景和资源**
4. 点击 **导出项目**

### 创建Steam depot
```
FantasyShooter/
├── FantasyShooter.exe    # 主程序
├── FantasyShooter.pck    # 资源包
└── steam_appid.txt       # Steam App ID（测试用）
```

## 3. Steamworks配置

### 创建应用
1. 登录 Steamworks
2. 点击 **创建新应用**
3. 选择 **游戏**
4. 填写游戏名称
5. 获得 **App ID**（如：1234560）

### 配置构建设置
1. 进入你的应用页面
2. 点击 **SteamPipe → 构建**
3. 创建Depot（内容仓库）
4. 下载 **Steamworks SDK**

### 创建steam_appid.txt
在测试时，创建文件 `steam_appid.txt`，内容为：
```
1234560  # 你的App ID
```

## 4. Steam SDK集成（代码）

### 添加Steam API脚本

```gdscript
# steam_manager.gd
extends Node

var is_steam_initialized: bool = false

func _ready():
	_initialize_steam()

func _initialize_steam():
	var init_result = Steam.steamInit()
	if init_result["status"] == 1:
		is_steam_initialized = true
		print("Steam初始化成功！")
		print("玩家名称：", Steam.getPersonaName())
	else:
		print("Steam初始化失败：", init_result["verbal"])

func _process(delta):
	if is_steam_initialized:
		Steam.runCallbacks()

# 解锁成就
func unlock_achievement(achievement_id: String):
	if is_steam_initialized:
		Steam.setAchievement(achievement_id)
		Steam.storeStats()

# 设置分数
func set_leaderboard_score(score: int):
	if is_steam_initialized:
		Steam.uploadLeaderboardScore(score, true, "KeepBest")
```

## 5. Steam功能实现

### 成就系统
```gdscript
# 定义成就ID（需在Steamworks后台配置）
const ACHIEVEMENTS = {
	"FIRST_KILL": "ACH_FIRST_KILL",
	"REACH_LEVEL_10": "ACH_LEVEL_10",
	"SURVIVE_5_MIN": "ACH_SURVIVE_5MIN",
	"KILL_100": "ACH_KILL_100"
}

# 解锁第一个击杀成就
func on_first_kill():
	SteamManager.unlock_achievement(ACHIEVEMENTS.FIRST_KILL)
```

### 云存档
```gdscript
# 保存游戏
func save_game():
	var save_data = {
		"high_score": high_score,
		"unlocked_weapons": unlocked_weapons,
		"play_time": total_play_time
	}
	
	var file = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	file.store_var(save_data)
	file.close()
	
	# Steam云存档会自动同步 user:// 目录的文件
```

### 排行榜
```gdscript
# 上传分数
func submit_score(score: int):
	SteamManager.set_leaderboard_score(score)

# 获取排行榜
func get_leaderboard():
	Steam.downloadLeaderboardEntries(1, 10, 0)
	# 结果会在 _on_leaderboard_scores_downloaded 回调中返回
```

## 6. 商店页面设置

### 基本信息
- **游戏名称**: Fantasy Shooter
- **类型**: 动作, 射击, Roguelike
- **标签**: 俯视射击, 像素风, 单人, 独立游戏
- **发布日期**: （待定）

### 商店描述模板
```
**关于游戏**
Fantasy Shooter是一款快节奏的俯视角射击游戏。在这个奇幻世界中，你将面对无尽的敌人浪潮，通过击杀敌人获得经验，不断升级变强！

**核心特色**
✓ 爽快的射击手感
✓ 丰富的升级系统
✓ 多种敌人类型
✓ 无尽挑战模式
✓ 支持手柄操作

**游戏玩法**
- 使用WASD移动，鼠标瞄准射击
- 空格键冲刺闪避
- 收集经验球升级
- 每升一级变得更强
- 生存越久，挑战越大

**系统需求**
最低配置：
- 操作系统：Windows 7/8/10/11
- 处理器：Intel Core i3
- 内存：4 GB RAM
- 显卡：集成显卡即可
- 存储空间：200 MB
```

## 7. 定价策略

### 建议定价
| 游戏规模 | 价格区间 |
|----------|----------|
| 小型Demo/原型 | 免费 |
| 小型完整游戏 | ¥15-30 / $2.99-4.99 |
| 中型独立游戏 | ¥30-60 / $4.99-9.99 |
| 大型独立游戏 | ¥60-100 / $9.99-19.99 |

### 首发折扣
- 建议首发 **-10% ~ -20%**
- 配合Steam促销活动

## 8. 发布流程

### 发布前检查清单
- [ ] 游戏无严重bug
- [ ] 所有素材已准备
- [ ] 商店页面完整
- [ ] 定价已设置
- [ ] 成就系统测试
- [ ] 云存档测试
- [ ] 手柄支持测试

### 提交审核
1. 在Steamworks点击 **发布 → 准备发布**
2. 选择发布日期
3. 提交审核（通常1-3个工作日）
4. 审核通过后，游戏会在设定日期自动发布

## 9. 发布后维护

### 重要事项
- **及时回复玩家评价**
- **修复bug发布更新**
- **根据反馈优化**
- **参与Steam促销活动**

### 更新日志模板
```
版本 1.0.1 - 2024/XX/XX
- 修复了XXXbug
- 优化了XXX性能
- 新增了XXX功能

版本 1.0.0 - 2024/XX/XX
- 游戏正式发布！
```

## 10. 营销推广

### 免费渠道
- B站/抖音游戏视频
- 贴吧/论坛发帖
- Reddit (r/IndieGaming)
- Twitter/X 游戏开发标签

### Steam功能
- Steam愿望单活动
- Steam新品节
- Steam每日特惠

### 建议
- 发布前至少积累 **500+ 愿望单**
- 制作吸引人的预告片
- 准备 press kit 给游戏媒体

---

## 时间线参考

| 阶段 | 时间 |
|------|------|
| 开发完成 | 第1-6个月 |
| Steam页面搭建 | 第5个月 |
| 愿望单积累 | 第5-6个月 |
| 最终测试 | 第6个月 |
| 正式发布 | 第6个月末 |

祝你的游戏大卖！🎮
