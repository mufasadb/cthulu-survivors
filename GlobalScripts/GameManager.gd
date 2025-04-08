extends Node

var custom_width: int = 1920
var custom_height: int = 1080


@export var player_scene_path: String = "res://player/player.tscn"
@export var player_scene: PackedScene
@export var location_for_players: Node
@export var debug_id_label: Label

func _ready():
	NetworkManager.enter_game()
	if player_scene_path == null:
		printerr("Player scene not set in Game Scene script!")
		get_tree().quit() # Or handle appropriately
		return
	#for each player in the lobby, add them to the game
	if NetworkManager.is_hosting:
		_add_player()
		for peer in multiplayer.get_peers():
			_add_player(peer)

	
	await get_tree().process_frame
	print($Arena)
	SignalBus.set_up_entity_signal.emit($Arena, SignalBus.SETUP_ENTITIES.ARENA_NODE)

	


func _add_player(id = 1):
	print('adding a new player' + str(id))
	var player_node = player_scene.instantiate()
	if player_node:
		player_node.name = str(id)
		call_deferred("add_child", player_node)
		match id:
			1: player_node.position = Vector2i(floor(custom_width / 2.0), floor(custom_height / 2.0))
			2: player_node.position = Vector2i(floor(custom_width / 2.0) + 100, floor(custom_height / 2.0))
			3: player_node.position = Vector2i(floor(custom_width / 2.0) - 100, floor(custom_height / 2.0))
			4: player_node.position = Vector2i(floor(custom_width / 2.0) + 200, floor(custom_height / 2.0))
	else:
		push_error("Failed to spawn player")
		player_node.set_multiplayer_authority(id)

func _connection_failed():
	printerr("connection failed")
	multiplayer.multiplayer_peer = null
	get_tree().change_scene_to_file("res://MenuUI/menu.tscn")

func _connected_ok():
	print("Connected to server!")

func _remove_player(id: int = 1):
	var player = get_node(str(id))
	player.queue_free()
		
func _exit_tree():
	if multiplayer.multiplayer_peer:
			multiplayer.multiplayer_peer.close()
			multiplayer.multiplayer_peer = null
