extends Node


signal player_fired_ability(action_resource: ActionResource, casters_action_manager: Node)

func _ready():
	print("signal bus ready")
#player fired should emit who fired it, and what they fired
