# base_player_data.gd
extends RefCounted
class_name BasePlayerData

# 唯一的存储中心
var _data: Dictionary = {}

## 注册/初始化
# 用于创造角色数据时调用，以区块为单位定义玩家数据构成，每个区块本身需要以字典作为结构
func register_module(module_name: String, default_values: Dictionary):
	_data[module_name] = default_values

# 【读写接口】
# 用于以区块为对象，读取或者写入区块内指定名称的数据，本质上是get字典
func set_val(module: String, key: String, value):
	if _data.has(module):
		_data[module][key] = value

func get_val(module: String, key: String, default = null):
	return _data.get(module, {}).get(key, default)

func get_module(module: String):
	return _data.get(module, {})

## 序列化 - 核心
# 将数据拍扁成 ConfigFile 能理解的纯字典，递归处理你那些“活的对象”
# 方便其他函数调用的，将当前玩家数据以字典返还
func to_dict() -> Dictionary:
	return _serialize_any(_data)

# 内部调用函数，递归读取数据并转换为字典
func _serialize_any(value):
	if value is Dictionary:
		var d = {}
		for k in value.keys():
			d[k] = _serialize_any(value[k])
		return d
	elif value is Array:
		var a = []
		for i in value:
			a.append(_serialize_any(i))
		return a
	elif value is Object and value.has_method("to_dict"):
		return value.to_dict()
	return value

## 反序列化 - 核心
func from_dict(serialized_data: Dictionary):
	# 简单的深拷贝，具体的“复活实例”逻辑建议在具体业务中处理，或在此扩展
	_data = serialized_data
