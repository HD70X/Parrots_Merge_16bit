extends Sprite2D

@export var spawn_y_offset: float = 40  # 生成位置的 Y 轴偏移
var _width: float

func _process(delta):
	# 跟随鼠标，但固定Y轴
	var mouse_pos = get_global_mouse_position()
	var click_x = mouse_pos.x
	var _right_check = click_x + _width
	var _left_check = click_x - _width
	if _right_check > 1854:
		click_x = 1854 - _width
	if _left_check < 66:
		click_x = 66 + _width
	global_position = Vector2(click_x, spawn_y_offset)

func update_preview(_throwable: ThrowableData):
	texture = _throwable.preview_tex
	_width = _throwable.width
