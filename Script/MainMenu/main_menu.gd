extends Node2D

@onready var start_button = $CanvasLayer/Control/MarginContainer/VBoxContainer/VBoxContainer/StarButton
@onready var level_button = $CanvasLayer/Control/MarginContainer/VBoxContainer/VBoxContainer/LevelsButton
@onready var setting_button = $CanvasLayer/Control/MarginContainer/VBoxContainer/VBoxContainer/SettingButton

# 预加载关卡数据
@onready var season_collection: SeasonCollection = preload("res://Resources/LevelConfig/season_collection.tres")

var default_season: SeasonConfig
var default_level: LevelConfig

func _ready() -> void:
	start_button.button_pressed.connect(_on_start_button_pressed)
	level_button.button_pressed.connect(_on_level_button_pressed)
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
	# 临时配置，打开默认关卡
	# LevelManager.start_level(load("res://Resources/level_season_01.tres"))
	LevelManager.start_level(load("res://Resources/LevelConfig/test_level_S01_L01.tres"), load("res://Resources/LevelConfig/test_season_01.tres"))

func _on_level_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scene/UI/level_select_menu.tscn")
