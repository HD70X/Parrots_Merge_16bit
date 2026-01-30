# game_main.gd
extends Node2D

@onready var input_handler = $GameWorld/InputHandler
@onready var spawner = $GameWorld/Spawner
@onready var next_preview = $GameWorld/PreviewSprite
@onready var spawner_container = $GameWorld/SpawnContainer
@onready var ui_manager = $UIManager
@onready var background = $Background

func _ready():
	# 连接信号：当点击发生时，执行 _on_drop
	input_handler.dropped.connect(_on_drop)
	spawner.prepare_next()
	GameEvent.signal_score_changed.emit(0) # 关卡启动时重置分数文本
	GameEvent.signal_retry_current_level.connect(restart_level)

func _on_drop(pos: Vector2):
	# 命令 Spawner 生成
	spawner.spawn(pos.x)

# 以后在这里扩展游戏结束逻辑
func _on_game_over():
	input_handler.enabled = false
	# UI_Manager.show_game_over()

func restart_level():
	spawner.prepare_next()
	GameEvent.signal_score_changed.emit(0)
