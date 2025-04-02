# NetworkManager.gd
extends Node

var is_hosting: bool = false
var target_ip: String = "localhost" # Default IP if joining
const DEFAULT_PORT = 135