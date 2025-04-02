class_name ActionComponent
extends Node

# --- Configuration ---
# Define slot structure: An array of dictionaries, each holding an active/support pair.
# ActionResource is assumed to be your custom resource type.
@export var action_slots: Array[ActionResource] = []

# Internal state
var cooldown_timers: Array = []
var parent: Node # The entity this component is attached to
var player_is_firing_action_slot: int = -1 

# --- Initialization ---
func _ready():
	parent = get_owner()
	if not parent:
		push_error("ActionComponent must have an owner (Player/Enemy)!")
	# Initialize cooldown timers (simple approach, could use Timers for more robustness)
	cooldown_timers.resize(action_slots.size())
	cooldown_timers.fill(0.0)

	# Connect signals
	SignalBus.player_fired_ability.connect(_execute_action)
		

func _process(delta):
	# Update cooldowns
	for i in range(cooldown_timers.size()):
		if cooldown_timers[i] > 0:
			cooldown_timers[i] -= delta
	if player_is_firing_action_slot != -1:
		SignalBus.player_fired_ability.emit(action_slots[slot_index], self)

		

# --- Public API ---

func equip_action(resource: Resource, slot_index: int):
	if slot_index < 0 or slot_index >= action_slots.size():
		push_warning("Invalid slot index for equipping action.")
		return
	if resource != null and not resource is ActionResource:
		push_warning("Invalid resource type provided to equip_action.")
		return
		
	# check if actions are full, if they are, unequip the action in that slot
	if action_slots[slot_index] and action_slots[action_slots.size() - 1]:
		unequip_action(slot_index)
		action_slots[slot_index] = resource
		return
	if action_slots[slot_index] and not action_slots[action_slots.size() - 1]:
		#loop through slots bigge than the target slot and move then up one, then add this action to the slot
		for i in range(slot_index + 1, action_slots.size()):
			action_slots[i - 1] = action_slots[i]
		action_slots[action_slots.size() - 1] = resource
		action_slots[slot_index] = resource
		return
	if action_slots[slot_index] == null:
		action_slots[slot_index] = resource
		return
	
		
func unequip_action(slot_index: int):
	if slot_index < 0 or slot_index >= action_slots.size():
		push_warning("Invalid slot index for unequipping action.")
	action_slots[slot_index] = null

func can_use_action(slot_index: int) -> bool:
	if slot_index < 0 or slot_index >= action_slots.size(): return false
	
	var active_resource = not action_slots[slot_index].tags.has(ActionResource.TAGS.SUPPORT)
	if not active_resource: return false # No action equipped
	if cooldown_timers[slot_index] > 0: return false # On cooldown
	
	return true

#listen for input of "fire" to trigger action
func _input(event):
	if event.is_action_pressed("fire") and is_multiplayer_authority():
		print("tried to fire")
		try_use_action(0)


# Main function to trigger an action from a slot index.
# target_data: Dictionary potentially containing target node, position, direction etc.
func try_use_action(slot_index: int):
	if not can_use_action(slot_index):
		print("Cannot use action in slot ", slot_index)
		return
	player_is_firing_action_slot = slot_index
	# --- Decide Action Behavior based on Support ---

		# No support or invalid support resource, execute active action directly
	# var executed_successfully = _execute_action(action_slots[slot_index], parent)
	# SignalBus.player_fired_ability.emit(action_slots[slot_index], self)


func _execute_action(resource: ActionResource, casters_action_manager: Node):
	#check if it was me who cast it, or it was another caster

	var caster = casters_action_manager.parent
	print("executing action: ", resource)
	if not resource.scene_path or resource.scene_path == "":
		push_error("ActionResource missing scene_path: ", resource)
		return
		
	var scene = load(resource.scene_path)
	if not scene:
		push_error("Failed to load action scene: ", resource.scene_path)
		return
		
	var action_instance = scene.instantiate()
	if not action_instance is BaseAction:
		push_error("Instantiated scene root is not BaseAction: ", resource.scene_path)
		action_instance.queue_free() # Clean up wrong instance
		return

	# Apply modifications BEFORE setting caster/resource or calling execute
	

	# Set essential properties

	# Add to scene tree (adjust parenting as needed, e.g., owner or world node)
	#TODO: make this muzzle position
	parent.add_child(action_instance) # Example: add to owner's parent
	if action_instance.has_node("Node2D") and caster.has_method("get_global_position"): # Rough position setting
		action_instance.global_position = caster.global_position

	action_instance.caster = caster
	# Execute
	action_instance.execute(BaseAction.TargetMethods.CLOSEST, resource.damage)
	
	return

	# if action_slots[slot_index].cooldown == 0:
	# 	push_error("Action ", action_slots[slot_index].action_name, " has no cooldown.")
	# 	return
	# var cooldown = action_slots[slot_index].cooldown if action_slots[slot_index].cooldown else 1.0
	# cooldown_timers[slot_index] = cooldown
		
		# Deduct cost (placeholder)
		# var mana_cost = active_resource.mana_cost if active_resource.has("mana_cost") else 0
		# owner_node.current_mana -= mana_cost
		
	
# Deploys a totem based on support resource config
# func _deploy_totem(active_res: ActionResource, support_res: ActionResource, target_data: Dictionary) -> bool:
# 	if not support_res.has("deployment_scene_path") or support_res.deployment_scene_path == "":
# 		push_error("Totem support resource missing deployment_scene_path: ", support_res)
# 		return false
		
# 	var scene = load(support_res.deployment_scene_path)
# 	if not scene: return false
	
# 	var totem_instance = scene.instantiate()
	
# 	# Pass necessary info to the totem
# 	if totem_instance.has_method("setup_totem"):
# 		totem_instance.setup_totem(parent, active_res) # Pass owner and the action it should cast
# 	else:
# 		push_warning("Totem scene lacks setup_totem(owner, action_resource) method.")

# 	# Determine position (example: at caster, could use target_data["position"])
# 	var deploy_pos = parent.global_position if parent.has_method("get_global_position") else Vector2.ZERO
	
# 	# Add to scene tree
# 	parent.get_parent().add_child(totem_instance)
# 	if totem_instance.has_node("Node2D"): # Rough position setting
# 	   totem_instance.global_position = deploy_pos

# 	print("Deployed totem for action: ", active_res.action_name)
# 	return true

# # Summons a pet based on support resource config
# func _summon_pet(active_res: ActionResource, support_res: ActionResource, target_data: Dictionary) -> bool:
# 	if not support_res.has("deployment_scene_path") or support_res.deployment_scene_path == "":
# 		push_error("Pet support resource missing deployment_scene_path: ", support_res)
# 		return false
		
# 	var scene = load(support_res.deployment_scene_path)
# 	if not scene: return false
	
# 	var pet_instance = scene.instantiate()
	
# 	# Pass necessary info to the pet
# 	if pet_instance.has_method("setup_pet"):
# 		pet_instance.setup_pet(parent, active_res) # Pass owner and the action it should cast
# 	else:
# 		push_warning("Pet scene lacks setup_pet(owner, action_resource) method.")

# 	# Determine position (example: at caster)
# 	var spawn_pos = parent.global_position if parent.has_method("get_global_position") else Vector2.ZERO
	
# 	# Add to scene tree
# 	parent.get_parent().add_child(pet_instance)
# 	if pet_instance.has_node("Node2D"): # Rough position setting
# 	   pet_instance.global_position = spawn_pos

# 	print("Summoned pet for action: ", active_res.action_name)
# 	return true

# # Helper to extract modification data from a support resource
# # Customize this based on how you store modification data in ActionResource
# func _gather_modifications(support_res: ActionResource) -> Dictionary:
# 	var mods = {}
# 	# Example: If support_res has 'chain_count_increase' export var
# 	if support_res.has("chain_count_increase") and support_res.chain_count_increase != 0:
# 		mods["chain_count"] = {"add": support_res.chain_count_increase}
# 	# Example: If support_res has 'damage_multiplier' export var
# 	if support_res.has("damage_multiplier") and support_res.damage_multiplier != 1.0:
# 		mods["damage"] = {"multiply": support_res.damage_multiplier} # Assumes active action has 'damage' prop
	# Add more logic here based on your ActionResource structure
	# return mods
