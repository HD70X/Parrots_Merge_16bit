extends MarginContainer

# 指向 CanvasGroup，因为 Shader 应该挂在它上面才能解决截断
@onready var canvas_group = $CanvasGroup
@onready var label = $CanvasGroup/Label
@onready var layout_label = $MarginContainer/VBoxContainer/Contents/VBoxContainer/LayoutLabel
@onready var margin_container_2 = $MarginContainer
@onready var button = $Button
@onready var current_star_number = $MarginContainer/VBoxContainer/Progress/Unlocked/HBoxContainer/Label
@onready var unlock_star_number = $MarginContainer/VBoxContainer/Progress/Locked/HBoxContainer/UnlockStars
@onready var unlocked_panel = $MarginContainer/VBoxContainer/Progress/Unlocked
@onready var locked_panel = $MarginContainer/VBoxContainer/Progress/Locked
@onready var season_texture = $MarginContainer/VBoxContainer/Contents/VBoxContainer/MarginContainer/TextureRect

# 数据参数
@export var _button_disabled: bool = false
# 需要脚本实例化时导入的参数
@export var _button_text: String = ""
@export var laber_transform = Vector2(0, 0)
@export var _unlocked = false
@export var collected_stars: int
@export var total_stars: int
@export var unlock_stars: int
@export var button_texture: Texture

var current_star_number_text: String = "{collected_stars}/{total_stars}"
var unlock_star_number_text: String = "{unlock_stars}"

# 预加载材质 (确保这些材质现在是 ShaderMaterial，且挂在 CanvasGroup 上)
var normal_material = preload("res://Art/Material/pixel_word_canvas.tres")
var disabled_material = preload("res://Art/Material/pixel_word_canvas(disable).tres")

signal button_pressed(season_id: String, unlock: bool)

var is_pointed = false
var is_pressed = false

func _ready() -> void:
	button.button_down.connect(_on_button_down)
	button.button_up.connect(_on_button_up)
	button.mouse_entered.connect(_on_mouse_entered)
	button.mouse_exited.connect(_on_mouse_exited)
	label.position += Vector2(42,6)
	_update_text_and_sync()

func _update_text_and_sync() -> void:
	# 基础按钮是否可点击（并非解锁）
	button.disabled = _button_disabled
	# 设定按钮文本参数
	layout_label.text = _button_text
	label.text = _button_text
	# 设置纹理并限制尺寸
	season_texture.texture = button_texture
	if button_texture:
		var texture_size = button_texture.get_size()
		var max_size = 200.0
		
		# 计算缩放比例（保持原始比例，且不超过 200x200）
		var scale_factor = 1.0
		if texture_size.x > max_size or texture_size.y > max_size:
			# 找出需要缩放的最大比例
			var scale_x = max_size / texture_size.x
			var scale_y = max_size / texture_size.y
			# 取较小的缩放比例，确保长宽都不超过限制
			scale_factor = min(scale_x, scale_y)
		
		# 应用缩放后的尺寸
		season_texture.custom_minimum_size = texture_size * scale_factor
		# 设置拉伸模式为保持比例
		season_texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
		season_texture.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	# 设置星星数量显示
	set_current_stars()
	set_unlock_stars()
	# 设置应该显示的面板
	unlocked_panel.visible = _unlocked
	locked_panel.visible = not _unlocked
	# 关联Label的文本浮动显示
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
		margin_container_2.position += laber_transform

func _on_button_up() -> void:
	is_pressed = false
	if is_pointed:
		margin_container_2.position -= laber_transform
		button_pressed.emit(_button_text, _unlocked)  # 转发信号

func _on_mouse_entered() -> void:
	is_pointed = true
	if is_pressed:
		margin_container_2.position += laber_transform

func _on_mouse_exited() -> void:
	is_pointed = false
	if is_pressed:
		margin_container_2.position -= laber_transform

func disable_button():
	_button_disabled = true
	_update_text_and_sync()

func enable_button():
	_button_disabled = false
	_update_text_and_sync()

func set_current_stars():
	var data = {
		"collected_stars": collected_stars,
		"total_stars": total_stars
	}
	current_star_number.text = current_star_number_text.format(data)

func set_unlock_stars():
	unlock_star_number.text = unlock_star_number_text.format({"unlock_stars": unlock_stars})
