extends Node

var custom_width: int = 1920
var custom_height: int = 1080


@export var player_scene_path: String = "res://player/player.tscn"
@export var player_scene: PackedScene
@export var multiplayer_spawner: MultiplayerSpawner
@export var location_for_players: Node
@export var debug_id_label: Label

func _ready():
	ArenaState.exp_bar = %ExpBar
	if player_scene_path == null:
		printerr("Player scene not set in Game Scene script!")
		get_tree().quit() # Or handle appropriately
		return

	if multiplayer_spawner == null:
		printerr("MultiplayerSpawner not set in Game Scene script!")
		get_tree().quit() # Or handle appropriately
		return

	if NetworkManager.is_hosting:
		_host_game()
	else:
		_join_game()
	await get_tree().process_frame
	if %HealthBar:
		ArenaState.health_bar = %HealthBar

func _host_game():
		await get_tree().process_frame
		NetworkManager.start_hosting()
		multiplayer.peer_connected.connect(_add_player)
		multiplayer.peer_disconnected.connect(_remove_player)
		_add_player()
		

func _join_game():
	NetworkManager.join_game()
	print("client started. Waiting for server..")


func _add_player(id = 1):
	print('adding a new player' + str(id))
	var player_node = player_scene.instantiate()
	if player_node:
		player_node.name = str(id)
		call_deferred("add_child", player_node)
		print(id)
		print(NetworkManager.peer.get_unique_id())
		match id:
			1: player_node.position = Vector2i(custom_width / 2, custom_height / 2)
			2: player_node.position = Vector2i(custom_width / 2 + 100, custom_height / 2)
			3: player_node.position = Vector2i(custom_width / 2 - 100, custom_height / 2)
			4: player_node.position = Vector2i(custom_width / 2 + 200, custom_height / 2)
	else:
		push_error("Failed to spawn player")
		player_node.set_multiplayer_authority(id)

func _connection_failed():
	printerr("connection failed")
	multiplayer.multiplayer_peer = null
	get_tree().change_scene_to_file("res://unsorted tscns/menu.tscn")

func _connected_ok():
	print("Connected to server!")

func _remove_player(id: int = 1):
	var player = get_node(str(id))
	player.queue_free()
		
func _exit_tree():
	if multiplayer.multiplayer_peer:
			multiplayer.multiplayer_peer.close()
			multiplayer.multiplayer_peer = null
