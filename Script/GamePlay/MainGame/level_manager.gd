# level_manager.gd (Autoload)
extends Node

# 单例配置
var current_config: LevelConfig
var season_config: SeasonConfig
var score: int = 0
var _primary_obj = false
var _secondary_obj = [false, false]

var game_over: bool = false

func _ready() -> void:
	# 关联信号
	GameEvent.signal_object_merged.connect(_once_merge)
	GameEvent.signal_fail_to_levelmanager.connect(_game_fail)
	GameEvent.signal_retry_current_level.connect(restart_level)
	GameEvent.signal_start_next_level.connect(start_next_level)
	# 发出信号

# 由 Main 调用，传入关卡配置路径或资源
func start_level(config: LevelConfig, _season_config: SeasonConfig):
	_reset_var()
	current_config = config
	season_config = _season_config
	# 核心步骤：通知对象池根据当前关卡重新洗牌
	ObjectPool.prepare_level(current_config)
	GameEvent.signal_level_loaded.emit(current_config)
	print("加载关卡: ", config.level_id)
	#print("主要目标：", current_config.primary_objectives.description)
	#for obj in current_config.secondary_objectives:
		#print("次要目标：", obj.description)
	#print("完成关卡初始化")
	game_over = false
	get_tree().change_scene_to_packed(config.level_scene)
	PlayerData.progression.record_default_level(_season_config.season_id, config.level_id)

func _game_fail(fail_reason: String):
	if game_over:
		pass
	else:
		game_over = true
		GameEvent.signal_show_fail.emit(fail_reason)

func _game_susseed(stars: int, secondary_1: bool, secondary_2: bool):
	if game_over:
		pass
	else:
		game_over = true
		GameEvent.signal_show_succeed.emit(stars)
		PlayerData.stars += stars
		PlayerData.progression.add_level_record(current_config.level_id, season_config.season_id, true, secondary_1, secondary_2, stars)
		var current_index = season_config.levels.find(current_config)
		if current_index != season_config.levels.size() - 1:
			var next_config = season_config.levels[current_index + 1]
			print(current_index, current_index + 1)
			print("解锁关卡: ", next_config.level_id)
			PlayerData.progression.add_level_record(next_config.level_id, season_config.season_id, false, false, false, 0)
			PlayerData.progression.record_default_level(season_config.season_id, next_config.level_id)
			SaveManager.save_def()

func restart_level():
	_reset_var()
	ObjectPool.return_all_active_objects()
	GameEvent.signal_level_loaded.emit(current_config)
	current_config.primary_objectives.is_completed = false
	#print("主要目标：", current_config.primary_objectives.description)
	for obj in current_config.secondary_objectives:
		obj.is_completed = false
	#print("完成关卡初始化")
	game_over = false

func _reset_var():
	score = 0
	_primary_obj = false
	_secondary_obj = [false, false]
	game_over = false

func start_next_level():
	var current_index = season_config.levels.find(current_config)
	if current_index != season_config.levels.size() - 1:
		var next_config = season_config.levels[current_index + 1]
		_reset_var()
		start_level(next_config, season_config)
	else:
		get_tree().change_scene_to_file("res://Scene/UI/level_select_menu.tscn")

# 内部逻辑，每次合成时安排参数变化，并相应相应检测
func _once_merge(new_data: ThrowableData, score_add: int):
	score += score_add
	if PlayerData.progression.discover_throwable(new_data.type_id):
		SaveManager.save_def()
	GameEvent.signal_score_changed.emit(score)
	_primary_obj = current_config.primary_objectives._check_each_merge(new_data, score, _primary_obj)
	var sec_i = 0
	for obj in current_config.secondary_objectives:
		_secondary_obj[sec_i] = obj._check_each_merge(new_data, score, _secondary_obj[sec_i])
		sec_i += 1
	# 运行一次关卡检测逻辑，判断是否完成
	_level_complete_check()

# 检查关卡本身主条件是否完成
func _level_complete_check():
	# 如果主任务完成，需要最后运行一次副任务最终检测逻辑完成情况验证
	var _stars: int = 1
	if _primary_obj:
		var sec_i = 0
		for obj in current_config.secondary_objectives:
			_secondary_obj[sec_i] = obj._check_before_result(_secondary_obj[sec_i])
			if _secondary_obj[sec_i]:
				_stars += 1
			sec_i += 1
		# 计算星星后进入完成环节
		_game_susseed(_stars, _secondary_obj[0], _secondary_obj[1])
