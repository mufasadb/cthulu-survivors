# AudioManager.gd (Conceptual Structure)
extends Node

@onready var bgm_player: AudioStreamPlayer = $BGMPlayer
@onready var sfx_players: Array[AudioStreamPlayer] = [$SFXPlayer1, $SFXPlayer2, $SFXPlayer3, $SFXPlayer4, $SFXPlayer5] # Add more as needed

const BGM_BUS_NAME = "BGM" # Match your bus names
const SFX_BUS_NAME = "SFX"

func _ready():
	# Load saved volumes, etc.
	pass

# --- Volume ---
func set_master_volume(volume_db : float):
	AudioServer.set_bus_volume_db(0, volume_db) # Bus 0 is usually Master

func set_bgm_volume(volume_db : float):
	var bus_idx = AudioServer.get_bus_index(BGM_BUS_NAME)
	if bus_idx != -1: AudioServer.set_bus_volume_db(bus_idx, volume_db)

func set_sfx_volume(volume_db : float):
	var bus_idx = AudioServer.get_bus_index(SFX_BUS_NAME)
	if bus_idx != -1: AudioServer.set_bus_volume_db(bus_idx, volume_db)

# --- Playback ---
func play_bgm(stream: AudioStream):
	if stream:
		bgm_player.stream = stream
		bgm_player.play()
	else:
		bgm_player.stop()

func play_sfx(stream: AudioStream, volume_offset_db: float = 0.0):
	if not stream: return

	for player in sfx_players:
		if not player.playing:
			player.stream = stream
			player.volume_db = volume_offset_db # Volume relative to SFX bus volume
			player.play()
			return # Played on this player

	# Optional: Warn if no player was available
	push_warning("AudioManager: No available SFX player found for stream.")