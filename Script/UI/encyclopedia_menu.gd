extends CanvasLayer

@onready var list_root = $Control/VBoxContainer/ScrollContainer/ListRoot
@onready var progress_label = $Control/VBoxContainer/TopBar/ProgressLabel

const MAIN_MENU_SCENE_PATH = "res://Scene/UI/main_menu.tscn"
const THROWABLES_DIR = "res://Resources/Parrots"

var progress_format = "Discovered: {count}/{total}"

func _ready() -> void:
	_build_throwable_list()

func _build_throwable_list() -> void:
	for child in list_root.get_children():
		child.queue_free()

	var all_throwables = _load_all_throwables()
	var discovered_count = 0

	for data in all_throwables:
		var unlocked = PlayerData.progression.is_throwable_discovered(data.type_id)
		if unlocked:
			discovered_count += 1
		list_root.add_child(_build_entry(data, unlocked))

	progress_label.text = progress_format.format({"count": discovered_count, "total": all_throwables.size()})

func _load_all_throwables() -> Array:
	var result: Array = []
	var dir = DirAccess.open(THROWABLES_DIR)
	if dir == null:
		push_error("Unable to open throwable directory: " + THROWABLES_DIR)
		return result

	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".tres"):
			var path = THROWABLES_DIR + "/" + file_name
			var data = load(path) as ThrowableData
			if data:
				result.append(data)
		file_name = dir.get_next()
	dir.list_dir_end()

	result.sort_custom(func(a: ThrowableData, b: ThrowableData): return a.type_id < b.type_id)
	return result

func _build_entry(data: ThrowableData, unlocked: bool) -> Control:
	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(0, 180)

	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_bottom", 12)
	panel.add_child(margin)

	var row = HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 24)
	margin.add_child(row)

	var icon_holder = CenterContainer.new()
	icon_holder.custom_minimum_size = Vector2(128, 128)
	row.add_child(icon_holder)

	var icon = TextureRect.new()
	icon.custom_minimum_size = Vector2(128, 128)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.texture = data.preview_tex
	icon_holder.add_child(icon)

	var shade = ColorRect.new()
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	shade.anchor_right = 1.0
	shade.anchor_bottom = 1.0
	shade.color = Color(0, 0, 0, 0.82) if not unlocked else Color(0, 0, 0, 0)
	icon_holder.add_child(shade)

	var info = VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_child(info)

	var title = Label.new()
	title.theme_override_font_sizes.font_size = 56
	title.text = data.type_id if unlocked else "???"
	info.add_child(title)

	var state = Label.new()
	state.theme_override_font_sizes.font_size = 36
	state.text = "Unlocked" if unlocked else "Locked"
	info.add_child(state)

	return panel

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file(MAIN_MENU_SCENE_PATH)
