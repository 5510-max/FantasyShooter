# Godot 4.x 入门教程

## 1. 安装Godot

### 下载
1. 访问 https://godotengine.org/
2. 下载 **Godot 4.x** 版本（推荐4.2或更新）
3. 解压到任意位置，双击运行

> 💡 不需要安装，解压即用！

## 2. 打开本项目

1. 打开Godot
2. 点击"导入"
3. 选择 `FantasyShooter/project.godot` 文件
4. 点击"打开"

## 3. Godot界面介绍

```
┌─────────────────────────────────────────────────────────┐
│  场景面板        │         2D/3D视图          │  检查器  │
│  (Scene)         │         (Viewport)         │(Inspector)│
│                  │                            │          │
│  - Main          │                            │  节点属性 │
│    - Player      │                            │          │
│    - Enemies     │                            │          │
│                  │                            │          │
├──────────────────┼────────────────────────────┤          │
│  文件系统         │         底部面板            │          │
│  (FileSystem)    │  输出 | 调试 | 动画 | 代码   │          │
│                  │                            │          │
│  - scripts/      │                            │          │
│  - scenes/       │                            │          │
│  - assets/       │                            │          │
└──────────────────┴────────────────────────────┴──────────┘
```

## 4. 核心概念

### 节点（Node）
- 游戏中的所有东西都是节点
- 节点可以有子节点，形成树状结构
- 每个节点有特定的功能

常见节点类型：
| 节点 | 用途 |
|------|------|
| Node2D | 2D物体的基础节点 |
| CharacterBody2D | 可控制的角色 |
| Area2D | 检测区域（如经验球） |
| Sprite2D | 显示图片 |
| Camera2D | 摄像机 |
| Timer | 计时器 |

### 场景（Scene）
- 场景是可复用的节点组合
- 保存为 `.tscn` 文件
- 可以实例化到其他场景中

### 脚本（Script）
- 使用GDScript语言
- 类似Python，非常易学
- 附加到节点上控制行为

## 5. GDScript基础语法

```gdscript
# 这是注释

# 变量声明
var health = 100
var speed: float = 200.0  # 指定类型
@export var damage: int = 10  # 可在编辑器中调整

# 函数
def my_function():
    print("Hello!")

# 内置函数
func _ready():  # 节点准备好时调用
    pass

func _process(delta):  # 每帧调用
    pass

func _physics_process(delta):  # 物理更新
    pass

# 条件判断
if health <= 0:
    die()
elif health < 30:
    warning()
else:
    normal()

# 循环
for i in range(5):
    print(i)

# 信号（事件）
signal health_changed

func take_damage():
    health_changed.emit(health)
```

## 6. 运行游戏

1. 点击右上角 **播放按钮** (▶)
2. 或按 **F5**

## 7. 调试技巧

- `print("调试信息")` - 输出到控制台
- 在代码行左侧点击设置断点
- 使用 **F9** 单步执行

## 8. 常用快捷键

| 快捷键 | 功能 |
|--------|------|
| F5 | 运行游戏 |
| F6 | 运行当前场景 |
| F7 | 停止运行 |
| Ctrl+S | 保存 |
| Ctrl+Z | 撤销 |
| F1 | 搜索帮助 |

## 下一步

→ [创建第一个场景](02-创建场景.md)
