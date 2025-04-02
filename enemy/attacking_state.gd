extends EnemyState

var initial_move_direction: Vector2
var distance_traveled_in_attack: float = 0
var time_since_attack: float = 0
@export var idle_state: EnemyState

func enter():
	super.enter()
	parent.velocity = Vector2.ZERO
	time_since_attack = 0
	parent.target = parent.find_nearest_player()
	initial_move_direction = parent.global_position.direction_to(parent.target.global_position)
	#assume the whole attack animation takes 1 second. 
	#change the animation speed, so that the animation finishes after parent.get_attack_duration()
	parent.animations.speed_scale = 1.0 / parent.get_attack_duration()

func exit():
	#if still in range + 10% deal damage
	if parent.global_position.distance_to(parent.target.global_position) < parent.attack_range * 1.1:
		parent.target._take_damage(parent.attack_damage)
	else: parent.target.textSpaffer.add_text_spaff("Miss")

func _process_physics(delta) -> EnemyState:
	time_since_attack += delta
	if time_since_attack > parent.get_attack_duration():
		return idle_state
	parent.velocity = initial_move_direction.normalized() * parent.attack_move_distance / parent.attack_speed
	parent.move_and_slide()
	
	
	return null
