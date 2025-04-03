extends Node2D


var game_scene: String = "res://unsorted tscns/main_game.tscn"
var menu_scene: String = "res://unsorted tscns/menu.tscn"
@export var lobby_player_scene: PackedScene
@export var start_game: Button = null

var player_positions = [
	Vector2(64 * 5, 0),
	Vector2(64 * 10, 0),
	Vector2(64 * 15 + 32, 0),
	Vector2(64 * 21 + 32, 0)
]


func _on_start_game_pressed():
	#tell all peers to change scene
	
	_change_scene.rpc(game_scene)


func _on_back_to_menu_pressed():
	NetworkManager.peer.close()
	_change_scene(menu_scene)


func _ready():
	await get_tree().process_frame
	NetworkManager.enter_lobby()
	if NetworkManager.is_hosting:
		NetworkManager.start_hosting()
		multiplayer.peer_connected.connect(_drop_player_in)
		multiplayer.peer_disconnected.connect(_remove_player)
		_drop_player_in()
	else:
		start_game.hide()
		NetworkManager.join_game()


func _remove_player():
	var player = get_node(str(NetworkManager.peer.get_unique_id()))
	player.queue_free()

func _drop_player_in(id= 1):
	if not lobby_player_scene:
		push_error("there was no lobby player scene")
		return

	var player = lobby_player_scene.instantiate()
	player.get_node("NameTag").text = str(id)
	player.name = str(id)
	self.add_child(player)
	player.position = player_positions[multiplayer.get_peers().size()]
	player.velocity = Vector2(0,100)


@rpc("any_peer", "call_local")
func _change_scene(scene: String):
	get_tree().change_scene_to_file(scene)
