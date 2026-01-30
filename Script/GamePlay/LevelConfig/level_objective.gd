# level_objective.gd
extends Resource
class_name LevelObjective

@export var description: String = "目标描述"

func _check_each_merge(new_data: ThrowableData, score: int, recorded_result: bool) -> bool:
	return false

func _check_before_result(recorded_result: bool) -> bool:
	return recorded_result
