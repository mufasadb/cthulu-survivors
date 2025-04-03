extends Node2D
class_name EnemyCharacter

@export var enemy_state_manager: EnemyStateManager
@export var animations: AnimatedSprite2D
var target: Player
@export var movement_speed: float = 40.
signal health_change

@export var _health: int = 100
@export var _max_health: int = 100

@export var exp_value: int = 1

@export_category("Attack")
@export var attack_range: float = 100
@export var attack_damage: int = 10
@export var attack_speed: float = 100
@export var attack_cooldown: float = 1
@export var attack_move_distance: float = 1


@onready var health_bar = $HealthBar

func get_attack_duration() -> float:
	return 100.0 / attack_speed

func _ready():
	enemy_state_manager.init(self)
	health_change.connect(health_bar.update_current)
	health_bar.update_max(_max_health)
	health_bar.update_current(_health, 0)


func find_nearest_player():
	return NodeFinder.find_closest("players", self.global_position, 2000, [], NodeFinder.ExclusionType.IGNORE)



func take_damage(amount: int):
	print(name + 'is taking' + str(amount) + 'damage')
	_health = clamp(_health - amount, 0, _max_health)
	health_change.emit(_health, -amount)
	if _health <= 0:
		_die()

func _die():
	enemy_state_manager.change_state(enemy_state_manager.die_state)
	

func _get_health():
	return _health
