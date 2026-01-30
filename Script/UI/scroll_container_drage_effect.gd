extends ScrollContainer

# 挂载在 season_list_root (ScrollContainer) 上的逻辑片段

var is_dragging: bool = false
var overscroll_buffer: float = 0.0 # 当前超出的偏移量

@export var bounce_stiffness: float = 0.3 # 阻力系数，越小越难拉
@export var spring_back_time: float = 0.4 # 回弹耗时

# 缩放效果
@export var min_scale: float = 0.5  # 边缘时的最小缩放
@export var max_scale: float = 1.0  # 中心时的最大缩放
@export var lerp_speed: float = 10.0 # 缩放平滑速度

func _ready():
	# 允许鼠标拖拽滚动（像素游戏更像手机体验）
	self.gui_input.connect(_on_gui_input)

func _process(delta: float):
	if self.visible:
		_update_scroll_scaling()
	if not is_dragging and overscroll_buffer != 0:
		# 松手后回弹
		overscroll_buffer = lerp(overscroll_buffer, 0.0, 10.0 * delta)
		if abs(overscroll_buffer) < 0.1: overscroll_buffer = 0
		_apply_stretch()

func _on_gui_input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			is_dragging = event.pressed
			
	if event is InputEventMouseMotion and is_dragging:
		var scroll_bar = self.get_v_scroll_bar()
		var current_val = scroll_bar.value
		
		# 检测是否到达顶部或底部
		if current_val <= 0 and event.relative.y > 0:
			# 向下拉（顶部超出）
			overscroll_buffer += event.relative.y * bounce_stiffness
			_apply_stretch()
		elif current_val >= (scroll_bar.max_value - self.size.y) and event.relative.y < 0:
			# 向上拉（底部超出）
			overscroll_buffer += event.relative.y * bounce_stiffness
			_apply_stretch()

func _apply_stretch():
	# 通过操作内部容器的 position 实现拉伸视觉效果
	self.position.y = overscroll_buffer

func _update_scroll_scaling():
	# 获取真正的按钮容器 (ScrollContainer 的第一个子节点通常是 VBoxContainer)
	# 建议在编辑器里把 VBoxContainer 拖进来或通过 get_child(0) 获取
	var vbox = get_child(0) 
	if not vbox: return

	# 1. 容器在屏幕上的中心 Y (保持不变)
	var container_center_y = global_position.y + (size.y / 2.0)
	
	# 计算拉伸减益
	var stretch_factor = clamp(1.0 - (abs(overscroll_buffer) / 1000.0), 0.6, 1.0)
	
	# 2. 遍历 VBox 内的按钮 (注意：排除掉 Spacer 占位符)
	for button in vbox.get_children():
		# 排除非 Control 节点，同时排除我们的占位符（假设它们叫 TopSpacer/BottomSpacer）
		if not button is Control or button.name.contains("Spacer"): 
			continue
		
		# 3. 核心修正：使用 global_position 获取按钮在屏幕上的实时中心点
		# global_position 会自动处理 ScrollContainer 的滚动偏移
		var button_center_y = button.global_position.y + (button.size.y / 2.0)
		
		# 4. 计算距离
		var offset_y = button_center_y - container_center_y
		var distance = max(0.0, offset_y)
		# var distance = abs(container_center_y - button_center_y)
		
		# 5. 缩放映射逻辑
		var max_dist = size.y / 1.2
		var t = clamp(distance / max_dist, 0.0, 1.0)
		
		# 计算最终缩放
		var target_scale_val = lerp(max_scale, min_scale, pow(t, 2))
		var final_scale = target_scale_val * stretch_factor
		
		# 6. 应用缩放与轴心
		button.scale = Vector2(final_scale, final_scale)
		# 像素对齐提示：Pivot 必须是 size 的一半，否则缩放会偏
		button.pivot_offset = button.size / 2.0
