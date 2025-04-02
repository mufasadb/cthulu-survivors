# ChainLightningAction.gd
# Extends BaseAction to implement a chain lightning effect.
extends BaseAction
class_name ChainLightningAction

## Maximum distance to find the first target from the caster.
@export var max_initial_range: float = 300.0
## Maximum distance to jump from the current target to the next.
@export var chain_range: float = 200.0
## Maximum number of targets (including the first one).
@export var chain_count: int = 3
## Delay in seconds between each chain jump.
@export var chain_delay: float = 0.1
## How long the lightning effect stays visible after the last hit (seconds).
@export var effect_duration: float = 0.5

## Reference to the Line2D node used for visuals. MUST be named "Visuals".
@onready var visuals: Node2D = $Visuals
@onready var lineNode: Line2D = visuals.get_node("Lightning")

var damage: int = 0

var hit_targets: Array[Node] = []


# Called externally after instantiation to start the action.
func execute(target_method := TargetMethods.CLOSEST, _damage := 0):
	if not caster or not is_instance_valid(caster):
		push_error("ChainLightningAction: Caster is not set or invalid!")
		finish_action() # Clean up immediately
		return

	if not visuals:
		push_error("ChainLightningAction: node2d node named 'Visuals' not found!")
		finish_action()
		return

	if not lineNode:
		push_error("ChainLightningAction: Line2D node named 'Lightning' not found!")
		finish_action()
		return

	#set essential properties
	damage = _damage

	# Reset state for this execution
	lineNode.points = []
	hit_targets.clear()

	
	# Add caster's position as the starting point for the line
	# Convert to local space of the Line2D node
	var caster_pos = caster.global_position
	# Find the first target
	var first_target = NodeFinder.find_closest("targets_for_players", caster_pos, max_initial_range, [], NodeFinder.ExclusionType.IGNORE)


	if first_target:
		# Start the chaining process asynchronously
		_start_chaining(first_target)

	else:
		# No target found, just end the action quickly after showing a small fizzle?
		# Optionally draw a short line stub or just clean up.
		# visuals.points = line_points # Show line start point briefly
		await get_tree().create_timer(0.1).timeout # Minimal visual time
		if is_instance_valid(self):
			finish_action()


func _process(_delta):
	if hit_targets.size() > 0:
		lineNode.points.clear()
		#move the visuals to the last target
		visuals.global_position = hit_targets[0].global_position
		lineNode.points = []
		for target in hit_targets:
			lineNode.add_point(lineNode.to_local(target.global_position))
		lineNode.add_point(lineNode.to_local(caster.global_position))
# Asynchronous function to handle the chain jumps with delays
func _start_chaining(current_target: Node):
	while is_instance_valid(current_target) and hit_targets.size() < chain_count:
		# Apply effect/damage to the current target
		hit_targets.insert(0, current_target)
		_apply_effect(current_target)

		# Check if we've reached the max number of chains
		if hit_targets.size() >= chain_count:
			break # Exit loop

		# Find the next target
		var next_target = NodeFinder.find_closest("targets_for_players", current_target.global_position, chain_range, hit_targets, NodeFinder.ExclusionType.AVOID)

		if next_target:
			# Wait for the chain delay
			await get_tree().create_timer(chain_delay).timeout
			# Check if this action node still exists before proceeding
			if not is_instance_valid(self): return
			current_target = next_target # Prepare for the next iteration
		else:
			lineNode.transform.origin = lineNode.to_local(current_target.global_position)
			break # No more valid targets found, exit loop

	# Chaining finished (max hits or no more targets)
	_end_chain_effect()


# Applies damage or other effects to a single target
func _apply_effect(target: Node):
	# Example: Apply damage using data from the ActionResource
	if target.has_method("take_damage"):
		if damage > 0:
			target.take_damage(damage)
	else: push_error("doesnt have take damage option")
	# print("Zapped: ", target.name) # Debugging


# Finds the nearest node in the "enemies" group within range, excluding specified nodes.
func _find_nearest_enemy(from_position: Vector2, range_limit: float, excluded) -> Node:
	var potential_targets = get_tree().get_nodes_in_group("targets_for_players")
	var nearest_enemy: Node = null
	var min_dist_sq = range_limit * range_limit # Use squared distance for efficiency


	for enemy in potential_targets:
		# Basic validation checks
		if not is_instance_valid(enemy) or enemy in excluded:
			continue
		

		var enemy_pos = enemy.global_position
		var dist_sq = from_position.distance_squared_to(enemy_pos)

		if dist_sq < min_dist_sq:
			min_dist_sq = dist_sq
			nearest_enemy = enemy
			
	return nearest_enemy

# Called after all chaining is complete to keep the visual for a duration.
func _end_chain_effect():
	# Wait for the specified effect duration
	await get_tree().create_timer(effect_duration).timeout
	# Ensure the node wasn't destroyed prematurely (e.g., caster died)
	if is_instance_valid(self):
		finish_action() # Call base cleanup (includes queue_free)

# Optional: Override finish_action if ChainLightning needs specific cleanup
# before queue_free happens in the base class.
# func finish_action():
#    # Custom cleanup for chain lightning before destroying
#    super.finish_action() # Call the base function to queue_free
