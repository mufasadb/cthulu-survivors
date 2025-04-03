extends EnemyState

@export var idle_state: EnemyState
@export var attacking_state: EnemyState

var check_target_frequency: float = 0.5
var last_target_check: float = 0

func _process_physics(delta) -> EnemyState:
	last_target_check += delta
	if last_target_check < check_target_frequency:
		parent.target = parent.find_nearest_player()
		last_target_check = 0
	if not parent.target:
		return idle_state
	#check if they're in attack range and if they are attack
	if parent.global_position.distance_to(parent.target.global_position) < parent.attack_range:
		return attacking_state
	else:
		# get direction to target, normalise, then ramp to full speed over 1 second
		var direction = parent.global_position.direction_to(parent.target.global_position)
		parent.velocity = direction.normalized() * parent.movement_speed
		parent.move_and_slide()
		if parent.velocity.x < 0:
			parent.animations.flip_h = true
		else:
			parent.animations.flip_h = false
		return null
	#flip if facing left
