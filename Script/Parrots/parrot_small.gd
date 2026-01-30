extends BaseThrowable

# 创建物理材质
func _ready():
	# contact_monitor = true
	max_contacts_reported = 8
	body_entered.connect(_on_body_entered)
	var physics_mat = PhysicsMaterial.new()
	physics_mat.friction = 0.1  # 增加摩擦力，减少滑动
	physics_mat.bounce = 0.02    # 降低弹性，减少反弹
	physics_material_override = physics_mat
	angular_damp = 1.2
	mass = 1
