# season_collection.gd
extends Resource
class_name SeasonCollection

@export var seasons: Array[SeasonConfig] = [] # Season列表，数组顺序即为解锁顺序
