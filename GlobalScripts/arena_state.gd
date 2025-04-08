extends Node


var _players: Array[Player] = []
var kill_count: int = 0
var exp_ball_scene: PackedScene = preload("res://unsorted tscns/exp_ball.tscn")
var exp_bar
var health_bar
var arena


var team_exp: int = 0
var level: int = 1

func _ready():
	SignalBus.set_up_entity_signal.connect(set_up_bars)
func update_bars(player):
	print("in the update bar, health bar and max health")
	print(health_bar)
	print(player._max_health)
	print(player._current_health)
	health_bar.update_max(player._max_health)
	health_bar.update_current(player._current_health, 100)

func attach_player(player: Player):
	_players.append(player)
	print("int the attach player function")
	print(player)
	print(health_bar)

	#check if player is control player or connected player
	
	#find HealthBar in GUI, connect player signals
	if player.is_multiplayer_authority():
		if health_bar:
			player.health_change_signal.connect(health_bar.update_current)
			player.health_total_change_signal.connect(health_bar.update_max)
			update_bars(player)
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
	if not arena:
		push_error("arena not found")
		return
	arena.add_child(exp_ball)
	exp_ball.exp_value = exp_value
	exp_ball.global_position = position

	
func set_up_bars(node: Node, type: SignalBus.SETUP_ENTITIES):
	print("added a new" + str(type))
	match type:
		SignalBus.SETUP_ENTITIES.HEALTH_BAR:
			health_bar = node
			print('health')
		SignalBus.SETUP_ENTITIES.EXP_BAR:
			exp_bar = node
			print("xp bar")
			print(exp_bar)
		SignalBus.SETUP_ENTITIES.ARENA_NODE:
			arena = node
	
func add_exp(amount: int):
	team_exp += amount
	if team_exp >= 100:
		level += 1
		team_exp = 0
	if not exp_bar:
		push_error("exp bar not found")
		return
	exp_bar.update_current(team_exp, amount)
