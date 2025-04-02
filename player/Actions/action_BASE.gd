extends Node

# BaseAction.gd
# Base class for all executable actions in the game.
# Attach this (or rather, a script extending this) to the root node
# of your action scene (.tscn).
class_name BaseAction


# The entity that triggered/is performing this action.
# Should be set externally after the action scene is instantiated.
var caster: Node
var tags: Array[ActionResource.TAGS]
# The ActionResource containing data (stats, costs, etc.) for this action.
# Should be set externally after the action scene is instantiated.
# Assuming you have a custom 'ActionResource' type defined elsewhere.
var action_resource: Resource


enum TargetMethods {
	CLOSEST,
	RANDOM,
	HIGHEST_HEALTH
}
# --- Core Execution Method ---

# This function MUST be overridden by extended action scripts.
# It contains the core logic for what the action does.
# target_data: A dictionary containing context like target node,
#              position, direction, etc., needed for the action.
func execute(target_method := TargetMethods.CLOSEST, _damage := 0):
    push_error("The 'execute' method must be overridden in the specific action script!")
    # Optional: You could put code here that *always* runs for any action,
    # either before or after calling super.execute() in the child class.

# --- Optional Helper Functions (Examples) ---

# Example: Call this from the extended script when the action is complete
# to ensure it cleans itself up.
func finish_action():
    # Add any other cleanup logic here if needed.
    queue_free()

# Example: Convenience function to get data from the resource
func get_damage() -> float:
    if action_resource and action_resource.has("damage"):
        return action_resource.damage
    return 0.0

func get_mana_cost() -> int:
    if action_resource and action_resource.has("mana_cost"):
        return action_resource.mana_cost
    return 0

# --- Godot Lifecycle Functions (Optional Use) ---

func _ready():
    # Connect signals from child nodes (AnimationPlayer, Timer, etc.) if needed.
    pass

func _process(delta):
    # Base processing logic if needed (rarely used directly here).
    pass

func _physics_process(delta):
    # Base physics logic if needed (rarely used directly here).
    pass