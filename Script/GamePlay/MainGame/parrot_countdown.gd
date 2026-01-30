extends AnimatedSprite2D

func play_countdown_animation():
	visible = true
	play("default")

func _on_animation_finished():
	visible = false
	queue_free()
