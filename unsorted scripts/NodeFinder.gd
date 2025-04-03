# NodeFinder.gd
# Add this script as an Autoload named "NodeFinder" in Project Settings.
extends Node


var collision_mask: int = 1

enum ExclusionType {
	IGNORE, AVOID, EXCLUDE
}

# Finds the closest node in a group within a given range.
# group: The group name to search.
# pos: The position (Vector2) to measure distance from.
# max_range: The maximum distance allowed.
# exclude: An array of nodes to ignore.

# Finds a random node in a group within a given range.
# Parameters are the same as find_closest.
func find_random_in_range(group: String, pos: Vector2, max_range: float, exclude: Array = [], exclusion_type: ExclusionType = ExclusionType.EXCLUDE) -> Node:
	var nodes_in_group = get_tree().get_nodes_in_group(group)
	var valid_nodes: Array[Node] = [] # Use typed array for clarity
	var max_dist_sq = max_range * max_range

	var avoidable_nodes: Array[Node] = []

	for node in nodes_in_group:
		if not is_instance_valid(node):
			continue
		if node in exclude:
			if exclusion_type == ExclusionType.AVOID:
				avoidable_nodes.append(node)
				continue
			if exclusion_type == ExclusionType.EXCLUDE:
				continue
		if not node is Node2D and not node is Node3D:
			continue

		var node_pos = node.global_position
		if pos.distance_squared_to(node_pos) < max_dist_sq:
			valid_nodes.append(node)

	if valid_nodes.is_empty():
		if not avoidable_nodes.is_empty():
			return avoidable_nodes.pick_random()
		return null
	else:
		# Return a random element from the filtered list
		return valid_nodes.pick_random()

# Finds the node with the highest 'current_health' property in a group within range.
# Assumes nodes in the group have a 'current_health: float' property.
# Parameters are the same as find_closest.
func find_highest_health(group: String, pos: Vector2, max_range: float, exclude: Array = [], exclusion_type: ExclusionType = ExclusionType.EXCLUDE) -> Node:
	var nodes_in_group = get_tree().get_nodes_in_group(group)
	var target_node: Node = null
	var max_health_found = - INF # Start with negative infinity
	var max_dist_sq = max_range * max_range
	var avoidable_nodes: Array[Node] = []

	for node in nodes_in_group:
		if not is_instance_valid(node):
			continue
		if not node is Node2D and not node is Node3D:
			continue

		if node in exclude:
			if exclusion_type == ExclusionType.AVOID:
				avoidable_nodes.append(node)
				continue
			if exclusion_type == ExclusionType.EXCLUDE:
				continue
		# Check if node has the health property BEFORE checking distance/health
		if not node.has("current_health"):
			# push_warning("Node %s in group %s missing 'current_health' property." % [node.name, group])
			continue

		var node_pos = node.global_position
		if pos.distance_squared_to(node_pos) < max_dist_sq:
			var node_health = node.get("current_health") # Use get() for safety maybe?
			if node_health is float and node_health > max_health_found:
				max_health_found = node_health
				target_node = node

	if target_node == null and not avoidable_nodes.is_empty():
		return avoidable_nodes.pick_random()
	return target_node

# Gets POTENTIALLY nearby nodes using physics space query
func _get_nearby_nodes_physics(space_rid: RID, pos: Vector2, max_range: float, _collision_mask:= collision_mask) -> Array:
	var query = PhysicsShapeQueryParameters2D.new()
	var shape = CircleShape2D.new()
	shape.radius = max_range
	
	query.transform = Transform2D(0.0, pos) # Angle 0, position pos
	query.shape = shape
	query.collision_mask = _collision_mask # Only detect nodes on these layers
	# query.exclude = [self_rid] # Optional: exclude the querier's physics body RID
	
	var space_state = PhysicsServer2D.space_get_direct_state(space_rid)
	var results: Array = space_state.intersect_shape(query) # Array of Dictionaries

	# Extract the actual nodes from the results
	var nearby_nodes: Array[Node] = []
	for result in results:
		if result.has("collider") and is_instance_valid(result.collider):
			# Check if it's the type of node you expect (optional but good)
			# if result.collider is EnemyClass: 
			nearby_nodes.append(result.collider)
			
	return nearby_nodes

# --- Gets all nodes in a group within range  ---
func all_in_range(group: String, pos: Vector2, max_range: float, exclude: Array = [], exclusion_type: ExclusionType = ExclusionType.EXCLUDE) -> Array:
	if exclusion_type == ExclusionType.AVOID:
		push_warning("ExclusionType.AVOID is not supported for all_in_range().")
	var nodes_in_group = get_tree().get_nodes_in_group(group)
	var valid_nodes: Array[Node] = [] # Use typed array for clarity
	var max_dist_sq = max_range * max_range

	for node in nodes_in_group:
		if not is_instance_valid(node):
			continue
		if node in exclude:
			if exclusion_type == ExclusionType.EXCLUDE:
				continue
		if not node is Node2D and not node is Node3D:
			continue

		var node_pos = node.global_position
		if pos.distance_squared_to(node_pos) < max_dist_sq:
			valid_nodes.append(node)

	return valid_nodes
	


# --- How you might use it in find_closest (conceptual) ---
func find_closest(group: String, pos: Vector2, max_range: float, exclude: Array = [], exclusion_type: ExclusionType = ExclusionType.EXCLUDE) -> Node:
	# Get the physics space RID (assuming Node2D context)
	var space = get_tree().root.world_2d.space


	var nodes_to_check = get_tree().get_nodes_in_group(group)
	var closest_node: Node = null
	var min_dist_sq = max_range * max_range # Still use range as precise limit
	var avoidable_nodes_closest: Node = null

	for node in nodes_to_check:
		# Already know it's potentially in range, now check exclusion + precise distance
		if not is_instance_valid(node):
			continue
		if node in exclude: # Check exclude list
			continue
			if exclusion_type == ExclusionType.AVOID:
				avoidable_nodes_closest = node
				continue
			if exclusion_type == ExclusionType.EXCLUDE:
				continue

		# No need to check if node is Node2D here, physics query ensures it's spatial

		var node_pos = node.global_position
		var dist_sq = pos.distance_squared_to(node_pos) # Precise check

		if dist_sq < min_dist_sq:
			# Check if node belongs to the target 'group' IF physics mask includes other things
			if node.is_in_group(group):
				min_dist_sq = dist_sq
				closest_node = node
			
	if closest_node == null and avoidable_nodes_closest:
		return avoidable_nodes_closest
	return closest_node

# Similar optimizations apply to find_random_in_range and find_highest_health
# by replacing get_nodes_in_group with the result of _get_nearby_nodes_physics
# and then applying the specific logic (random, health check) to the smaller list.