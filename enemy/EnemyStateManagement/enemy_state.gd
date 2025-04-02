class_name EnemyState
extends Node

@export
var animation_name: String
var parent: EnemyCharacter

func enter() -> void:
	parent.animations.play(animation_name)
	#do extra non inherited stuff

func exit() -> void:
	pass

func _process_input(event: InputEvent) -> EnemyState:
	return null

func _process_frame(delta: float) -> EnemyState:
	return null

func _process_physics(delta: float) -> EnemyState:
	return null
