extends Control

@onready var animtion_player = $Sprites/AnimationPlayer
	
func _play_into():
	animtion_player.play("into")
