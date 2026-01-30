extends GeneralGameButton

var stars: int
var level_config: LevelConfig
@onready var star_slot_disable = $Button/StarControl/StarSlotDisable
@onready var star_slot = $Button/StarControl/StarSlot
@onready var star_1 = $Button/StarControl/Stars/MarginContainer/HBoxContainer/Star_1
@onready var star_2 = $Button/StarControl/Stars/MarginContainer/HBoxContainer/Star_2
@onready var star_3 = $Button/StarControl/Stars/MarginContainer/HBoxContainer/Star_3
@onready var star_control = $Button/StarControl

func _update_text_and_sync() -> void:
	button.disabled = _button_disabled
	layout_label.text = _button_text
	label.text = _button_text
	if button.disabled:
		star_slot_disable.visible = true
		star_slot.visible = false
	else:
		star_slot_disable.visible = false
		star_slot.visible = true
	
	star_1.visible = stars >= 1
	star_2.visible = stars >= 2
	star_3.visible = stars >= 3
	
	# 1. 强制更新布局逻辑，确保本帧计算出正确的对齐位置
	layout_label.get_parent().queue_sort() 
	
	# 2. 关键：等待布局完成。
	# 只有在下一帧，或者 call_deferred 之后，layout_label 的真实位置才是准确的
	await get_tree().process_frame 
	
	# 3. 放弃手动加 Vector2(42, 6)，改用全域坐标同步
	# 这会无视 MarginContainer 的内部偏移、居中对齐带来的位移、以及字体差异
	if is_instance_valid(label) and is_instance_valid(layout_label):
		label.global_position = layout_label.global_position
		
	# 4. 更新材质
	canvas_group.material = disabled_material if _button_disabled else normal_material

func _on_button_down() -> void:
	is_pressed = true
	if is_pointed:
		layout_label.position += laber_transform
		star_control.position += laber_transform

func _on_button_up() -> void:
	is_pressed = false
	if is_pointed:
		layout_label.position -= laber_transform
		star_control.position -= laber_transform
		button_pressed.emit()  # 转发信号

func _on_mouse_entered() -> void:
	is_pointed = true
	if is_pressed:
		layout_label.position += laber_transform
		star_control.position += laber_transform

func _on_mouse_exited() -> void:
	is_pointed = false
	if is_pressed:
		layout_label.position -= laber_transform
		star_control.position -= laber_transform
