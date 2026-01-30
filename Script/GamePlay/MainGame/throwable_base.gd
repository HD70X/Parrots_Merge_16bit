# throwable_base.gd
extends RigidBody2D
class_name BaseThrowable

var data: ThrowableData # 在每个球的 .tscn 根节点拖入对应的 .tres

var is_merging: bool = false  # 添加合成标记
var merge_cooldown: float = 0.0
const MERGE_COOLDOWN_TIME = 0.1  # 100毫秒冷却
var active_tween: Tween
var danger_zone_warning: float = 0.5
var danger_zone_timeout: float = 3.5

@onready var sprite = $Sprite2D
# @onready var countdown_timer = $CountdownTimer
@onready var danger_zone_warning_timer = $DangerZoneWarningTimer
@onready var danger_zone_timeout_timer = $DangerZoneTimeoutTimer
@onready var remote_transform = $RemoteTransform2D

func _ready():
	# contact_monitor = true
	max_contacts_reported = 4
	body_entered.connect(_on_body_entered)

func _process(delta):
	if merge_cooldown > 0:
		merge_cooldown -= delta

func _on_body_entered(body):
	if data == null:
		push_error("错误：物体 " + name + " 缺失 ThrowableData！")
		return
	if not data.mergeable:
		return
	# 如果正在合成，直接返回
	if is_merging or merge_cooldown > 0:
		return
	if body is BaseThrowable:
		var other = body as BaseThrowable
		
		# 检查对方是否也在合成中
		if other.is_merging:
			return
		
		if other.data.mergeable and data.type_id == other.data.type_id:
			# 只让 ID 较小的物体执行合成逻辑
			if get_instance_id() > other.get_instance_id():
				return
			# 标记双方都在合成中
			is_merging = true
			other.is_merging = true
			merge_with(other)

func merge_with(other: BaseThrowable):
	# 检查是否有下一级形态
	if not data.next_form:
		return 
		
	# 获取下一级的场景路径（作为对象池的 Key）
	var next_data = data.next_form
	
	# 执行合成逻辑（复用你之前的 call_deferred 逻辑）
	call_deferred("_do_merge", other, next_data)

func _do_merge(other, next_data):
	# 从池中获取
	var new_obj = ObjectPool.get_object(next_data)
	
	# 设置位置并添加
	var spawn_pos = global_position.lerp(other.global_position, 0.5)
	new_obj.global_position = spawn_pos
	get_parent().add_child(new_obj)
	
	# 发射合成信号，包含合成对象，增加分数
	var marge_score = data.score_value
	GameEvent.signal_object_merged.emit(next_data, marge_score)
	
	# 播放动画
	new_obj.play_spawn_animation()
	
	# 归还旧对象
	ObjectPool.return_object(self)
	ObjectPool.return_object(other)

func play_spawn_animation():
	self.process_mode = Node.PROCESS_MODE_INHERIT
	
	# 1. 停止並清理舊動畫
	if active_tween and active_tween.is_valid():
		active_tween.kill()
	
	# 2. 強制重置尺寸（這是為了對象池重複使用）
	sprite.scale = Vector2(0.1, 0.1)
	
	# 3. 創建 Tween
	active_tween = create_tween()
	# 確保即使遊戲暫停，這個動畫也能播（可選）
	# active_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS) 
	
	active_tween.set_ease(Tween.EASE_OUT)
	active_tween.set_trans(Tween.TRANS_BACK)
	
	active_tween.tween_property(sprite, "scale", Vector2.ONE, 0.3)
	
	active_tween.finished.connect(_on_spawn_animation_finished)

func _on_spawn_animation_finished():
	apply_central_impulse(Vector2(randf_range(-10, 10), 10))
	# 動畫結束後釋放引用，方便垃圾回收
	active_tween = null 

func start_countdown():
	# 重新开始计时(如果已在运行会自动重置)
	if not is_inside_tree() or is_merging:
		return
	if danger_zone_warning_timer and danger_zone_warning_timer.is_inside_tree():
		danger_zone_warning_timer.start()
		danger_zone_timeout_timer.start()

func _on_danger_zone_warning_timer_timeout():
	# countdown_timer.play_countdown_animation()
	GameEvent.signal_body_danger_zone.emit(self)

func _on_danger_zone_timeout_timer_timeout():
	var fail_reason = "Into Limition"
	GameEvent.signal_fail_to_levelmanager.emit(fail_reason)

func stop_countdown():
	#if countdown_timer:
		#countdown_timer._on_animation_finished()
	danger_zone_warning_timer.stop()
	danger_zone_timeout_timer.stop()
