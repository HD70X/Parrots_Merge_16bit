# season_config.gd
@tool
extends Resource
class_name SeasonConfig

@export var season_id: String
@export var season_name: String
@export var season_button_texture: Texture
@export var unlock_stars_required: int # 解锁此 Season 需要的总星星数
@export var total_stars: int
@export var levels: Array[LevelConfig] # 关卡列表，数组顺序即为解锁顺序

@export_tool_button("计算总星数", "Play")
var my_button = _calculate_stars

# 自动计算星星数量
func _calculate_stars():
	var stars = 0
	for level in levels:
		stars += 3
	total_stars = stars
	if Engine.is_editor_hint():
		emit_changed()
	notify_property_list_changed()
	ResourceSaver.save(self, self.resource_path)
	print("SeasonConfig 已保存: ", total_stars)
