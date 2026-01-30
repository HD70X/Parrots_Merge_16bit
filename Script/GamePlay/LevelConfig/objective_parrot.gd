extends LevelObjective
class_name ParrotObjective

@export var target_parrot: ThrowableData

func _check_each_merge(new_data: ThrowableData, score: int, recorded_result: bool):
	if recorded_result:
		return true
	else:
		return new_data.type_id == target_parrot.type_id
