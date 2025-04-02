extends EnemyState

@export var enemy_run_state: EnemyState
@export var attacking_state: EnemyState

func _ready():
	assert(enemy_run_state != null, "enemy_run_state must be set")

func enter():
	super.enter()
	parent.velocity = Vector2.ZERO


func _process_frame(_delta) -> EnemyState:
	parent.target = parent.find_nearest_player()
	if parent.target:
		if parent.global_position.distance_to(parent.target.global_position) < (parent.attack_range + parent.attack_move_distance):
			return attacking_state
		return enemy_run_state
	return null
