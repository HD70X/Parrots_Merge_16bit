# danger_zone.gd
extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body is BaseThrowable:
		# 检查物体是否真的在游戏场景中
		if body.is_inside_tree() and not body.is_queued_for_deletion():
			# 额外检查:确保不是对象池的子节点
			if body.get_parent() != ObjectPool:
				# print(body, "进入区域，触发倒计时")
				body.start_countdown()

func _on_body_exited(body: Node2D) -> void:
	if body is BaseThrowable and body.is_inside_tree():
		body.stop_countdown()
		GameEvent.signal_body_out_danger_zone.emit(body)
