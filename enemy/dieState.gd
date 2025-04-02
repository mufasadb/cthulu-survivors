extends EnemyState


var time_to_die: float = 4.0
var time_dieing: float = 0


func _process_frame(delta: float) -> EnemyState:
	parent.remove_from_group("targets_for_players")
	time_dieing += delta
	if time_dieing > 0.9: 
		parent.animations.pause()
	if time_dieing > time_to_die:
			ArenaState.enemy_died(parent.global_position)
			parent.queue_free()
	return null
