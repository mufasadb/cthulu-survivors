extends Node
class_name EnemyStateManager

@export var starting_state: EnemyState
var current_state: EnemyState
@export var die_state: EnemyState

@export var character_node: EnemyCharacter = null
var parent: EnemyCharacter


func init(_parent: EnemyCharacter) -> void:
	parent = _parent
	assert(_parent != null, "Parent must not be null")
	for child in get_children():
		child.parent = _parent
	if (starting_state == null):
		return
	change_state(starting_state)

func change_state(new_state: EnemyState) -> void:
	if current_state:
		current_state.exit()

	current_state = new_state
	current_state.enter()


func _process(delta: float) -> void:
	if (parent._get_health() == 0):
		change_state(die_state)
	var new_state = current_state._process_frame(delta)
	if new_state:
		change_state(new_state)


func _physics_process(delta: float) -> void:
	var new_state = current_state._process_physics(delta)
	if new_state:
		change_state(new_state)
