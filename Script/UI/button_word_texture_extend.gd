# 挂载到 Label 上的脚本
@tool
extends Label

func _ready():
	# 这里的数值根据你的投影大小调整，向四周扩展渲染区域
	var margin = 10
	var custom_rect = Rect2(Vector2(-margin, -margin), size + Vector2(margin * 2, margin * 2))
	RenderingServer.canvas_item_set_custom_rect(get_canvas_item(), true, custom_rect)
