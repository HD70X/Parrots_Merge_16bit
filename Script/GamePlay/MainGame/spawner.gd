# spawner.gd
extends Node2D

@onready var spawn_container = get_node("../SpawnContainer") # 根据路径获取
@onready var preview_sprite = get_node("../PreviewSprite")
@export var spawn_y_offset: float = 40

var next_throwable: ThrowableData

func prepare_next():
	next_throwable = get_next_drop_data()
	preview_sprite.update_preview(next_throwable)

func spawn(click_x: float):
	var throwable = ObjectPool.get_object(next_throwable)
	var _width: float = next_throwable.width
	var _right_check = click_x + _width
	var _left_check = click_x - _width
	if _right_check > 1854:
		click_x = 1854 - _width
	if _left_check < 66:
		click_x = 66 + _width
	throwable.global_position = Vector2(click_x, spawn_y_offset)
	throwable.rotation = 0
	spawn_container.add_child(throwable)
	if PlayerData.progression.discover_throwable(next_throwable.type_id):
		SaveManager.save_def()
	
	throwable.call_deferred("play_spawn_animation")
	
	# 准备下一个
	prepare_next()

static func get_next_drop_data() -> ThrowableData:
	# 1. 安全检查：确保关卡已加载
	var config = LevelManager.current_config
	if not config:
		push_error("SpawnerService: 尝试在未加载关卡时获取生成数据！")
		return null
	
	# 2. 获取当前关卡的权重表
	var weights = config.drop_weights
	if weights.is_empty():
		push_error("SpawnerService: 当前关卡配置中 drop_weights 为空！")
		return null

	# 3. 经典的权重随机算法
	var total_weight = 0
	for w in weights.values():
		total_weight += w
	
	var roll = randi() % total_weight
	var cursor = 0
	
	for data in weights.keys():
		cursor += weights[data]
		if roll < cursor:
			return data
			
	return weights.keys() # 兜底返回第一个
