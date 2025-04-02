extends MultiplayerSpawner

# This function will be called via RPC from the GameManager on the server.
# It runs locally on the server to perform the actual spawn.
# The MultiplayerSpawner automatically replicates the spawned node to clients.
@rpc("any_peer", "call_local")
func spaw_function(scene_path: String, args: Array) -> Node:
	if not multiplayer.is_server():
		return # Should only execute on the server

	var peer_id = args[0] # Extract the peer ID from the arguments

	# Instantiate the scene
	var scene = load(scene_path)
	if not scene:
		printerr("Spawn Error: Cannot load scene ", scene_path)
		return

	var node = scene.instantiate()
	if not node:
		printerr("Spawn Error: Cannot instantiate scene ", scene_path)
		return

	# Set the node's name to the peer ID. Crucial for identification.
	node.name = str(peer_id)

	# Set multiplayer authority immediately.
	node.set_multiplayer_authority(peer_id)

	print("Spawner: Spawning ", scene_path, " for peer ", peer_id, " with authority.")

	# Add the node as a child using the spawner's configured spawn_path
	add_child(node)
	return node

	# Optional: You could pass more data from 'args' to configure the node here
	# if node.has_method("initialize_player"):
	#     node.initialize_player(args[1], args[2]) # Example: position, name
