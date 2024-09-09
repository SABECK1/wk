extends ProgressBar

func _on_player_take_damage(health: int) -> void:
	self.value = health
