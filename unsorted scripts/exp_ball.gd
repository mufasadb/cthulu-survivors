extends Node2D

var exp_value: int = 1
var player_to_move_toward: Player
var check_suckability_frame_frequency: int = 10
var frame_count: int = 0
var movement_speed: float = 1000

var size = 15


func _physics_process(delta):
	frame_count += 1
	if frame_count < check_suckability_frame_frequency:
		return
	else:
		frame_count = 0
		_check_players_to_be_sucked_by()

	if player_to_move_toward:
		global_position = global_position.move_toward(player_to_move_toward.global_position, movement_speed * delta)
		if global_position.distance_to(player_to_move_toward.global_position) < size * 2:
			ArenaState.add_exp(exp_value)
			queue_free()
		

func _check_players_to_be_sucked_by():
	for player in ArenaState._players:
		if not player:
			push_error("there wasn't any players")
			return
		if player.global_position.distance_to(global_position) < player.exp_suck_range:
			player_to_move_toward = player
