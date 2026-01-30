# input_handler.gd
extends Node

signal dropped(pos: Vector2) # 定义投掷信号

@export var release_cd: float = 0.8
var is_cding: bool = false
var enabled: bool = true # 用于游戏暂停或结束时禁用输入

func _unhandled_input(event):
	if not enabled or is_cding: return
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			is_cding = true
			dropped.emit(event.position) # 发出信号给指挥官
			
			await get_tree().create_timer(release_cd).timeout
			is_cding = false
