class_name TextSpaffer
extends Control
var damage_numbers = []


func add_text_spaff(text: String) -> void:
	var label = Label.new()
	label.text = text
	label.modulate = Color(1, 0, 0, 1)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.custom_minimum_size = Vector2(50, 50)
	label.position = Vector2(randf_range(0, 150), randf_range(0, 150))
	
	add_child(label)
	damage_numbers.append(label)
	#have number appear, go up, fall down and fade out
	
	var tween = create_tween()
	tween.tween_property(label, "position", label.position + Vector2(0, 50), 1.0).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(label, "modulate:a", 0, 3.0).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
	tween.finished.connect(func(): _on_tween_completed(label))

# Clean up damage numbers
func _on_tween_completed(label: Label) -> void:
	if label in damage_numbers:
		damage_numbers.erase(label)
	label.queue_free()
