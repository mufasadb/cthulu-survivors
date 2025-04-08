# Menu scene script (e.g., menu.gd)
extends Control

# Add an LineEdit node in your menu scene for the IP address, name it IpAddressInput
# @onready var ip_address_input = $IpAddressInput 
var ip_address: String = 'localhost'

var game_scene: String = "res://MenuUI/main_game.tscn"

var lobby_scene: String = "res://MenuUI/lobby.tscn"

func _on_new_game_button_pressed():
	NetworkManager.is_hosting = true
	# Ensure you have the correct path to your game scene
	get_tree().change_scene_to_file(game_scene)

func _on_host_game_button_pressed():
	NetworkManager.is_hosting = true
	# Ensure you have the correct path to your game scene
	get_tree().change_scene_to_file(lobby_scene)

func _on_join_game_button_pressed():
	NetworkManager.is_hosting = false
	var input_ip = ip_address
	# Use default if input is empty, otherwise use input
	NetworkManager.target_ip = "localhost" if input_ip.is_empty() else input_ip
	# Ensure you have the correct path to your game scene
	get_tree().change_scene_to_file(lobby_scene)
