extends LevelObjective
class_name ScoreObjective

@export var target_score: int = 1000

func _check_each_merge(new_data: ThrowableData, score: int, recorded_result: bool) -> bool:
	if recorded_result:
		return true
	else:
		return score >= target_score
