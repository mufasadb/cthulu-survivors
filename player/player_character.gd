extends CharacterBody2D
class_name Player


@export var movement_speed: float = 40.0
var _max_health: int = 100
var _current_health: int:
	get: return _current_health

@export var character_health: int = 100

@export var textSpaffer: TextSpaffer
@export var exp_suck_range: float = 100

signal health_change_signal
signal health_total_change_signal
	
func _ready():
	ArenaState.attach_player(self)
	if textSpaffer:
		health_change_signal.connect(textSpaffer.add_text_spaff)
	else:
		push_error("no text spaffer")
	_current_health = character_health
	_max_health = character_health
	set_multiplayer_authority(name.to_int())

func _physics_process(_delta):
	_movement()

	

func _movement():
	if is_multiplayer_authority():
		var x_mov = Input.get_action_strength("right") - Input.get_action_strength("left")
		var y_mov = Input.get_action_strength("down") - Input.get_action_strength("up")
		var mov = Vector2(x_mov, y_mov)
		velocity = mov.normalized() * movement_speed
	move_and_slide()

#health setter
func _take_damage(amount: int):
	print("hit" + str(amount))
	var health_change = - amount
	_current_health = clamp(_current_health - amount, 0, _max_health)
	var new_health = clamp(_current_health, 0, _max_health)
	health_change_signal.emit(new_health, health_change)
	if _current_health == 0:
		_die()
		
func _update_max_health(new_max_health: int):
	_max_health = new_max_health
	health_total_change_signal.emit(_max_health)

func _die():
	ArenaState.release_player(self)
	print("died")
	queue_free()
