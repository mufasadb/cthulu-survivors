# NetworkManager.gd
extends Node

var is_hosting: bool = false
var target_ip: String = "localhost" # Default IP if joining
const DEFAULT_PORT = 135

var peer = ENetMultiplayerPeer.new()

var multiplayer_spawner: MultiplayerSpawner
var mutli_spawner_scene: PackedScene = preload("res://MenuUI/custom_multiplayer_spawner.tscn")

var lobby_player_scene: String = "res://MenuUI/lobby_player.gd"
var game_player_scene: String = "res://player/player.tscn"
var game_enemy_scene: String = "res://enemy/enemy.tscn"

func _ready():
	multiplayer_spawner = mutli_spawner_scene.instantiate()
	self.add_child(multiplayer_spawner)
	#run sync enemies to new playesrs
func start_hosting():
	peer.create_server(DEFAULT_PORT)
	multiplayer.multiplayer_peer = peer

func join_game():
	peer.create_client(target_ip, DEFAULT_PORT)
	multiplayer.multiplayer_peer = peer

func is_server() -> bool:
	return is_hosting


func enter_lobby():
	# pass
	multiplayer_spawner.spawn_path = "/root/Lobby"
	# multiplayer_spawner.add_spawnable_scene(lobby_player_scene)
	

func enter_game():
	multiplayer_spawner.spawn_path = "../../GameManager"
	# multiplayer_spawner.add_spawnable_scene(game_player_scene)
