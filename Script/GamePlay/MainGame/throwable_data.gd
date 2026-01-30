# throwable_data.gd
@tool
extends Resource
class_name ThrowableData

@export_group("基础信息")
@export var type_id: String
@export var mergeable: bool = false

@export var scene: PackedScene
@export var preview_tex: Texture2D  # 用于 UI 预览图

@export_tool_button("生成宽度", "Play")
var my_button = _calculate_width_from_scene

@export_group("合成逻辑")
@export var next_form: ThrowableData # 链式关联：指向下一级的 .tres 资源
@export var score_value: int = 10    # 合成时提供的分数

@export var width: float

func _calculate_width_from_scene():
	if not scene:
		return 0.0
	# 实例化场景来获取尺寸
	var instance = scene.instantiate()
	var calculated_width = 0.0
	print("开始计算宽度,场景: ", scene.resource_path)  # 调试输出
	for child in instance.get_children():
		if child is CollisionShape2D:
			print("找到 CollisionShape2D")  # 调试输出
			var shape = child.shape
			var local_extent = 0.0
			
			if shape is CapsuleShape2D:
				# 获取胶囊体参数
				var radius = shape.radius
				var height = shape.height
				var rotation = child.rotation  # 获取节点旋转角度
				
				# 胶囊体的局部尺寸(未旋转时)
				var local_width = radius * 2
				var local_height = height
				
				# 计算旋转后的包围盒
				# 使用旋转矩阵计算四个关键点
				var cos_r = abs(cos(rotation))
				var sin_r = abs(sin(rotation))
				
				# 旋转后的宽度 = 原宽度*cos + 原高度*sin
				var rotated_width = local_width * cos_r + local_height * sin_r
				
				# 加上位置偏移
				local_extent = abs(child.position.x) + rotated_width / 2
			elif shape is CircleShape2D:
				local_extent = abs(child.position.x) + shape.radius
			
			calculated_width = max(calculated_width, local_extent)
	print("计算结果: ", calculated_width)  # 调试输出
	instance.queue_free()
	width = calculated_width
	if Engine.is_editor_hint():
		emit_changed()  # 通知 Godot 资源已改变
		# 或者使用:
		# resource_changed()
	return
