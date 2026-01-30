# level_select_menu.gd
extends CanvasLayer

var seasons_list: Dictionary
var level_list: Dictionary

@onready var season_list_root = $Control/VBoxContainer/MarginContainer/SeasonButtonRoot
@onready var level_list_root = $Control/VBoxContainer/MarginContainer/LevelButtonRoot
@onready var season_button_list = $Control/VBoxContainer/MarginContainer/SeasonButtonRoot/VBoxContainer
@onready var level_button_list = $Control/VBoxContainer/MarginContainer/LevelButtonRoot/GridContainer
@onready var confirm_panel = $Control/CenterContainer/ConfirmationDialog
@onready var notice_panel = $Control/CenterContainer/NoticeDialog
@onready var player_stars_label = $Control/VBoxContainer/TopControlBar/HBoxContainer/PlayersStars

# 预加载关卡数据
@onready var season_collection: SeasonCollection = preload("res://Resources/LevelConfig/season_collection.tres")

# 预加载Season和Leval按钮场景
@export var season_button_secne: PackedScene
@export var level_button_secne: PackedScene
@export var main_menu_secne: PackedScene

var selected_season: SeasonConfig
var player_stars_label_text: String = "{stars}"

func _ready() -> void:
	_refresh_stars()
	_build_season_list()
	confirm_panel.left_pressed.connect(_confirm_season_unlock)
	confirm_panel.right_pressed.connect(_cancel_season_unlock)
	season_list_root.visible = true
	level_list_root.visible = false

# 基于配置信息构建seasons_list
func _build_season_list():
	# 清理旧按钮
	for child in season_button_list.get_children():
		child.queue_free()
	var empty_container_1 = MarginContainer.new()
	empty_container_1.custom_minimum_size.y = 600
	season_button_list.add_child(empty_container_1)
	for season_config in season_collection.seasons:
		print("set_season: ", season_config.season_name)
		# 按照Season配置添加按钮
		var _button = season_button_secne.instantiate()
		season_button_list.add_child(_button)
		_button._button_text = season_config.season_name
		_button._unlocked = PlayerData.progression.is_season_onlocked(season_config.season_id)
		_button.collected_stars = PlayerData.progression.get_season_status(season_config.season_id)
		_button.total_stars = season_config.total_stars
		_button.unlock_stars = season_config.unlock_stars_required
		_button.button_texture = season_config.season_button_texture
		# 刷新按钮（数据和按钮关联）
		_button._update_text_and_sync()
		# 关联按钮信号
		_button.button_pressed.connect(_on_season_button_pressed.bind(season_config))
	var empty_container_2 = MarginContainer.new()
	empty_container_2.custom_minimum_size.y = 600
	season_button_list.add_child(empty_container_2)
# 基于配置信息和season_id构建该season的level_list

# 处理season按钮的信号处理
func _on_season_button_pressed(_season_id: String, _unlock: bool, season_config: SeasonConfig):
	if _unlock:
		selected_season = season_config
		_enter_season(selected_season)
		# 清空缓存
		selected_season = null
	else:
		confirm_panel.title_text = "Ready for More?"
		confirm_panel.massage_text = "Unlock " + season_config.season_name + " and explore new challenges!\n\nRequired: " + str(season_config.unlock_stars_required) + "stars."
		confirm_panel._build_dialog()
		confirm_panel.visible = true
		selected_season = season_config
		# print("show unlock conditions")

func _confirm_season_unlock():
	if selected_season == null:
		print("Error: No season config available")
		return
	# 关闭确认对话框
	confirm_panel.visible = false
	# 检查玩家星星数
	if PlayerData.stars >= selected_season.unlock_stars_required:
		# 扣除星星
		PlayerData.stars -= selected_season.unlock_stars_required
		_refresh_stars()
		# 解锁season
		PlayerData.progression.unlock_season(selected_season.season_id)
		SaveManager.save_def()
		# 刷新列表
		_build_season_list()
		# 进入该season
		_enter_season(selected_season)
		# 清空缓存
		selected_season = null
		# print("succeed unlocked")
	else:
		# 星星不足提示
		notice_panel.visible = true
		notice_panel.title_text = "Not Enough Stars"
		notice_panel.massage_text = "You need " + str(selected_season.unlock_stars_required - PlayerData.stars) + " more stars to unlock this season."
		notice_panel._build_dialog()
		# print("fail unlocked")

func _cancel_season_unlock():
	# 关闭对话框
	# print("cancel unlock")
	confirm_panel.visible = false

func _enter_season(_season_config: SeasonConfig):
	_build_levels_list(_season_config)
	season_list_root.visible = false
	level_list_root.visible = true

func _build_levels_list(_season_config: SeasonConfig):
	# 清理旧按钮
	for child in level_button_list.get_children():
		child.queue_free()
	var _level_issue = 0
	for level_config in _season_config.levels:
		print("set_level: ", level_config.level_id)
		_level_issue += 1
		# 按照Season配置添加按钮
		var _button = level_button_secne.instantiate()
		level_button_list.add_child(_button)
		_button._button_text = str(_level_issue)
		if PlayerData.progression.unlocked_level.has(level_config.level_id):
			_button.stars = PlayerData.progression.unlocked_level[level_config.level_id]["stars"]
		else:
			if _level_issue != 1:
				_button._button_disabled = true
		_button._update_text_and_sync()
		_button.button_pressed.connect(_open_level.bind(level_config, _season_config))

func _open_level(_level_config: LevelConfig, _season_config: SeasonConfig):
	LevelManager.start_level(_level_config, _season_config)

func _on_back_button_pressed() -> void:
	if notice_panel.visible or confirm_panel.visible:
		confirm_panel.visible = false
		notice_panel.visible = false
	elif level_list_root.visible:
		season_list_root.visible = true
		level_list_root.visible = false
	elif season_list_root.visible:
		get_tree().change_scene_to_packed(main_menu_secne)

func _refresh_stars():
	player_stars_label.text = player_stars_label_text.format({"stars": " " + str(PlayerData.stars) + " "})
