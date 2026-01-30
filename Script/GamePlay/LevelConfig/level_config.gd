# level_config.gd
@tool
extends Resource
class_name LevelConfig

@export var level_id: String
@export var level_scene: PackedScene

@export_group("掉落配置")
## 键是球的数据，值是权重（整数）。例如：{Ball01: 70, Ball02: 30}
@export var drop_weights: Dictionary[ThrowableData, int] = {}:
	set(value):
		drop_weights = value
		# 自动添加新项
		if Engine.is_editor_hint(): # 确保只在编辑器内运行
			_on_drop_weights_changed()

@export_group("对象池")
## 只有当你需要手动覆盖默认数量时才填这个字典
@export var pool_overrides: Dictionary[ThrowableData, int] = {}
@export var default_pool_size: int = 15

@export_group("条件")
@export var primary_objectives: LevelObjective   # 主要目标
@export var secondary_objectives: Array[LevelObjective] # 次要目标(星级评价)

# 自动添加新项
func _on_drop_weights_changed():
	for item in drop_weights.keys():
		if item and not pool_overrides.has(item):
			pool_overrides[item] = default_pool_size
	
	# (可选) 自动清理：如果权重表里没了，池子覆盖表也删掉（除非你想手动保留）
	# for item in pool_overrides.keys():
	#     if not drop_weights.has(item):
	#         pool_overrides.erase(item)
	
	notify_property_list_changed()
