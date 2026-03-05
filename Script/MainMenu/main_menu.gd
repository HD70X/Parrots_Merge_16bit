extends Node2D

@onready var start_button = $CanvasLayer/Control/MarginContainer/VBoxContainer/VBoxContainer/StarButton
@onready var level_button = $CanvasLayer/Control/MarginContainer/VBoxContainer/VBoxContainer/LevelsButton
@onready var setting_button = $CanvasLayer/Control/MarginContainer/VBoxContainer/VBoxContainer/SettingButton
@onready var encyclopedia_button = $CanvasLayer/Control/MarginContainer/VBoxContainer/VBoxContainer/EncyclopediaButton

# 预加载关卡数据
@onready var season_collection: SeasonCollection = preload("res://Resources/LevelConfig/season_collection.tres")

var default_season: SeasonConfig
var default_level: LevelConfig

func _ready() -> void:
	start_button.button_pressed.connect(_on_start_button_pressed)
	level_button.button_pressed.connect(_on_level_button_pressed)
	encyclopedia_button.button_pressed.connect(_on_encyclopedia_button_pressed)
	if PlayerData.progression.default_next_level.get("season_id"):
		for _season_config in season_collection.seasons:
			if _season_config.season_id == PlayerData.progression.default_next_level.get("season_id"):
				default_season = _season_config
				for _level_config in _season_config.levels:
					if _level_config.level_id == PlayerData.progression.default_next_level.get("level_id"):
						default_level = _level_config
						return
	else:
		start_button.visible = false

func _on_start_button_pressed() -> void:
	var default_level_data = PlayerData.progression.default_next_level
	
	# 检查是否有保存的默认关卡
	if default_level_data.is_empty() or not default_level_data.has("season_id") or not default_level_data.has("level_id"):
		# 没有保存记录，加载第一关
		_load_first_level()
		return
	
	var season_id = default_level_data["season_id"]
	var level_id = default_level_data["level_id"]
	
	# 查找对应的 Season 配置
	var _season_collection = load("res://Resources/LevelConfig/season_collection.tres") as SeasonCollection
	var target_season: SeasonConfig = null
	
	for season in _season_collection.seasons:
		if season.season_id == season_id:
			target_season = season
			break
	
	if target_season == null:
		print("未找到 Season: ", season_id, "，加载默认第一关")
		_load_first_level()
		return
	
	# 查找对应的关卡配置
	var target_level: LevelConfig = null
	for level in target_season.levels:
		if level.level_id == level_id:
			target_level = level
			break
	
	if target_level == null:
		print("未找到关卡: ", level_id, "，加载默认第一关")
		_load_first_level()
		return
	
	# 成功找到，加载关卡
	LevelManager.start_level(target_level, target_season)

# 加载默认第一关的辅助函数
func _load_first_level() -> void:
	var first_season = load("res://Resources/LevelConfig/test_season_01.tres") as SeasonConfig
	var first_level = load("res://Resources/LevelConfig/test_level_S01_L01.tres") as LevelConfig
	LevelManager.start_level(first_level, first_season)

func _on_level_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scene/UI/level_select_menu.tscn")

func _on_encyclopedia_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scene/UI/encyclopedia_menu.tscn")
