@tool
extends Control
class_name Fillabe_Bar


@export_category("colour")
@export var fill_color: Color = Color(0, 1, 0, 1)
@export var text_color: Color = Color(1, 1, 1, 1)
@export_category("sizes")
@export var custom_width: int = 200:
	get : return custom_width
	set(new_value):
		custom_width = new_value
		_update_bar_size()
@export var custom_height: int = 40:
	get: return custom_height
	set(new_value):
		custom_height = new_value
		_update_bar_size()

var max_value: float = 100
var current_value: float = 0
@export var animate_change: bool = true
@export var text_enabled: bool = true

var progress_bar: ProgressBar
var label: Label

func _ready() -> void:
	progress_bar = $progress_bar
	label = $text_display
	update_bar()

func update_bar() -> void:
	progress_bar.value = current_value
	progress_bar.max_value = max_value
	progress_bar.modulate = fill_color
	label.visible = text_enabled
	label.text = str(current_value) + "/" + str(max_value)
	label.modulate = text_color

	#update size
	_update_bar_size()

	#move left assuming origin is centre
	
func _update_bar_size():
	if not progress_bar:
		await ready


	progress_bar.size.x = custom_width
	progress_bar.size.y = custom_height
	label.size.x = custom_width
	label.size.y = custom_height

func update_max(new_max: int) -> void:
	max_value = new_max
	update_bar()

func update_current(new_current: int, change: int) -> void:
	# slide up to new point
	if animate_change:
		current_value = new_current
		var tween = create_tween()
		tween.tween_property(progress_bar, "ratio", current_value / max_value, 1)
	else:
		current_value = new_current
		progress_bar.ratio = current_value / max_value

	label.text = str(current_value) + "/" + str(max_value)
	# update_bar()


func update_color(new_fill_color: Color, new_text_color: Color) -> void:
	fill_color = new_fill_color
	text_color = new_text_color
	update_bar()
