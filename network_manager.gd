# NetworkManager.gd
extends Node

var is_hosting: bool = false
var target_ip: String = "localhost" # Default IP if joining
const DEFAULT_PORT = 135

var peer = ENetMultiplayerPeer.new()

func start_hosting():
	peer.create_server(DEFAULT_PORT)
	multiplayer.multiplayer_peer = peer

func join_game():
	peer.create_client(target_ip, DEFAULT_PORT)
	multiplayer.multiplayer_peer = peer