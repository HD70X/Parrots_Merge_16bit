# ui_manager.gd
extends CanvasLayer

@onready var pause_screen = $UIRoot/PauseScreen
@onready var fail_screen = $UIRoot/FailScreen
@onready var fail_reason = $UIRoot/FailScreen/VBoxContainer/Reason
@onready var succeed_screen = $UIRoot/SucceedScreen
@onready var parrot_timer_layer = $UIRoot/ParrotTimer
@onready var score_label = $UIRoot/MarginContainer/HBoxContainer/ScoreLabel
@onready var star_1 = $UIRoot/SucceedScreen/VBoxContainer/MarginContainer/HBoxContainer/Star
@onready var star_2 = $UIRoot/SucceedScreen/VBoxContainer/MarginContainer/HBoxContainer/Star2
@onready var star_3 = $UIRoot/SucceedScreen/VBoxContainer/MarginContainer/HBoxContainer/Star3

var animated_sprite_scene = preload("res://Scene/Parrets/parrot_countdown.tscn")
var score_label_text = "Score: {score}"

func _ready() -> void:
	#订阅信号
	GameEvent.signal_show_fail.connect(_show_fail)
	GameEvent.signal_show_succeed.connect(_show_succeed)
	GameEvent.signal_body_danger_zone.connect(show_parrot_timer)
	GameEvent.signal_body_out_danger_zone.connect(hid_parrot_timer)
	GameEvent.signal_score_changed.connect(change_score_ui)

func _show_succeed(stars: int):
	star_1.visible = false
	star_1.visible = false
	star_1.visible = false
	succeed_screen.visible = true
	if stars >= 1:
		star_1.visible = true
		star_1._play_into()
	if stars >= 2:
		await get_tree().create_timer(0.5).timeout
		star_2.visible = true
		star_2._play_into()
	if stars >= 3:
		await get_tree().create_timer(0.8).timeout
		star_3.visible = true
		star_3._play_into()

func _show_fail(reason: String):
	fail_screen.visible = true
	fail_reason.text = reason

func show_parrot_timer(body):
	var sprite_instance = animated_sprite_scene.instantiate()
	parrot_timer_layer.add_child(sprite_instance)
	body.remote_transform.remote_path = sprite_instance.get_path()
	sprite_instance.play_countdown_animation()

func hid_parrot_timer(body):
	# 通过 remote_transform 的路径找到倒计时节点
	if body.remote_transform and body.remote_transform.remote_path:
		var sprite_instance = get_node_or_null(body.remote_transform.remote_path)
		if sprite_instance and is_instance_valid(sprite_instance):
			sprite_instance.queue_free()
			body.remote_transform.remote_path = ""  # 清空路径

func change_score_ui(score: int):
	score_label.text = score_label_text.format({"score": score})

func _return_to_level_select():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scene/UI/level_select_menu.tscn")

func _retry_level():
	get_tree().paused = false
	get_tree().reload_current_scene()
	GameEvent.signal_retry_current_level.emit()

func _pause():
	get_tree().paused = true
	# GameEvent.signal_pause_game.emit()
	pause_screen.visible = true

func _play():
	get_tree().paused = false
	# GameEvent.signal_containue_game.emit()
	pause_screen.visible = false

func _next_level():
	GameEvent.signal_start_next_level.emit()
