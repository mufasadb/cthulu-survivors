extends Node

var custom_width: int = 1920
var custom_height: int = 1080


@export var player_scene: PackedScene

var peer = ENetMultiplayerPeer.new()

func _ready():
	ArenaState.exp_bar = %ExpBar
	if player_scene == null:
		printerr("Player scene not set in Game Scene script!")
		get_tree().quit() # Or handle appropriately
		return

	if NetworkManager.is_hosting:
		await get_tree().process_frame
		peer.create_server(NetworkManager.DEFAULT_PORT)
		multiplayer.multiplayer_peer = peer
		multiplayer.peer_connected.connect(_add_player)
		_add_player()
		print("server started. Waiting for players..")

	if %HealthBar:
		ArenaState.health_bar = %HealthBar
		
func _add_player(id:int=1):
	var player = player_scene.instantiate()
	player.name= str(id)
	print("adding player: ", player.name)
	call_deferred("add_child", player)
	match id:
		1: player.position = Vector2(custom_width/2, custom_height/2)
		2: player.position = Vector2(custom_width/2 + 100, custom_height/2)
		3: player.position = Vector2(custom_width/2 - 100, custom_height/2)
		4: player.position = Vector2(custom_width/2 + 200, custom_height/2)

func _connection_failed():
	printerr("connection failed")
	multiplayer.multiplayer_peer = null
	get_tree().change_scene_to_file("res://unsorted tscns/menu.tscn")

func _connected_ok():
	print("Connected to server!")
		
func _exit_tree():
	if multiplayer.multiplayer_peer:
			multiplayer.multiplayer_peer.close()
			multiplayer.multiplayer_peer = null
