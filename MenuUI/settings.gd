extends Control

@onready var resolution = DisplayServer.screen_get_size()
@onready var master_volume_slider = $Panel/MarginContainer/VBoxContainer/Volume
@onready var SFX_volume_slider = $Panel/MarginContainer/VBoxContainer/SFXVolume
@onready var BGM_volume_slider = $Panel/MarginContainer/VBoxContainer/BGMVolume
@onready var mute_check_box = $"Panel/MarginContainer/VBoxContainer/Mute Checkbox"
@onready var resolution_drop_down = $Panel/MarginContainer/VBoxContainer/Resolutions
@onready var fullscreen_option = $Panel/MarginContainer/VBoxContainer/Fullscreen

var magic_scale = 80

func _on_master_volume_value_changed(value):
	#map 0 to off and 1 to max volume of the linear db range
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Master"), value / magic_scale)

func _on_mute_c_heckbox_toggled(button_pressed):
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), button_pressed)

func _on_sfx_volume_value_changed(value):
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("SFX"), value / magic_scale)

func _on_bgm_volume_value_changed(value):
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("BGM"), value / magic_scale)

func _on_resolutions_item_selected(id):
	match id:
		0:
			DisplayServer.window_set_size(Vector2i(1280, 720))
		1:
			DisplayServer.window_set_size(Vector2i(1920, 1080))
		2:
			DisplayServer.window_set_size(Vector2i(2560, 1080))
		3:
			DisplayServer.window_set_size(Vector2i(2560, 1440))
		4:
			DisplayServer.window_set_size(Vector2i(3440, 1440))

func _on_fullscreen_item_selected(id):
	match id:
		0:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		1:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		2:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
			


func _ready():
	master_volume_slider.value = AudioServer.get_bus_volume_linear(AudioServer.get_bus_index("Master")) * magic_scale
	SFX_volume_slider.value = AudioServer.get_bus_volume_linear(AudioServer.get_bus_index("SFX")) * magic_scale
	BGM_volume_slider.value = AudioServer.get_bus_volume_linear(AudioServer.get_bus_index("BGM")) * magic_scale
	mute_check_box.button_pressed = AudioServer.is_bus_mute(AudioServer.get_bus_index("Master"))
	print(DisplayServer.screen_get_size())
	for i in range(resolution_drop_down.get_item_count()):
		var resolution = resolution_drop_down.get_item_text(i)
		print(resolution)
		if resolution == str(DisplayServer.screen_get_size()):
			resolution_drop_down.select(i)
			break
