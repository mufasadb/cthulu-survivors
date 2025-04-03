extends Node


@export var enemy_scenes: Array[EnemyType] = []
var time = 0
var spawn_frequency = 5.0 # Adjust this value to control the spawn frequency
@onready var game_manager_node = $"../"
var valid_spawn_cells = []
var tilemap_layer_to_spawn_on: TileMapLayer

func _ready():
	if not enemy_scenes[0]:
		push_error("enemy_scenes array is empty. Please add at least one EnemyType resource.")
	# spawn enemy 5 times
	tilemap_layer_to_spawn_on = %Dirt

	if not NetworkManager.is_hosting:
		return
	await get_tree().process_frame
	find_valid_spawn_position()
	for _i in range(5):
		var spawn_cell = valid_spawn_cells.pick_random()
		spawn_enemy.rpc(spawn_cell)


func _process(delta):
	if not NetworkManager.is_server():
		return
	time += delta
	if time >= spawn_frequency:
		var spawn_cell = valid_spawn_cells.pick_random()
		spawn_enemy.rpc(spawn_cell)
		time = 0
	

@rpc("any_peer", "call_local")
func spawn_enemy(spawn_cell):
	var enemy_scene = enemy_scenes.pick_random()
	var enemy = load(enemy_scene.scene_path).instantiate()
	game_manager_node.add_child(enemy, true)
	enemy.global_position = spawn_cell * 64 + Vector2i(32, 32)
	#assign a random position in the arena


func find_valid_spawn_position():
	valid_spawn_cells.clear()
	
	var used_cells: Array[Vector2i] = tilemap_layer_to_spawn_on.get_used_cells()
	
	for cell_coords: Vector2i in used_cells:
# Get the TileData for this specific cell coordinate on this layer
		var tile_data: TileData = tilemap_layer_to_spawn_on.get_cell_tile_data(cell_coords)
		
		if tile_data and tile_data.get_custom_data("is_spawnable"):
			valid_spawn_cells.append(cell_coords)
