extends Node


var _players: Array[Player] = []
var kill_count: int = 0
var exp_ball_scene: PackedScene = preload("res://unsorted tscns/exp_ball.tscn")
@onready var exp_bar
@onready var health_bar

var team_exp: int = 0
var level: int = 1

func update_bars():
	health_bar = %HealthBar
	health_bar.update_max(_players[0]._max_health)
	health_bar.update_current(_players[0]._current_health, 0)

func attach_player(player: Player):
	_players.append(player)
	print(player)
	#check if player is control player or connected player
	
	#find HealthBar in GUI, connect player signals
	if player.is_multiplayer_authority():
		if health_bar:
			print(health_bar)
			player.health_change_signal.connect(health_bar.update_current)
			player.health_total_change_signal.connect(health_bar.update_max)
		else:
			push_error("health bar not found")


func release_player(player: Player):
	_players.erase(player)


func get_players():
	return _players


func enemy_died(position: Vector2, exp_value: int = 1):
	kill_count += 1
	#spawn exp ball
	var exp_ball = exp_ball_scene.instantiate()
	$Arena.add_child(exp_ball)
	exp_ball.exp_value = exp_value
	exp_ball.global_position = position


func add_exp(amount: int):
	team_exp += amount
	if team_exp >= 100:
		level += 1
		team_exp = 0
	if not exp_bar:
		push_error("exp bar not found")
		return
	exp_bar.update_current(exp, amount)
