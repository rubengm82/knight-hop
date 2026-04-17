extends Control

@onready var button_back: Button = $VBoxContainer/Button_BACK
@onready var vbox: VBoxContainer = $VBoxContainer
@onready var header_container: HBoxContainer = $VBoxContainer/HBoxContainer
@onready var header_name_label: Label = $VBoxContainer/HBoxContainer/Label_NAMES
@onready var header_sec_label: Label = $VBoxContainer/HBoxContainer/Label_SEC

func _ready() -> void:
	button_back.pressed.connect(_on_back_pressed)
	_display_scores()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("fullscreen_windowed_switch"):
		_toggle_fullscreen()


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://src/ui/menu/menu.tscn")


func _display_scores() -> void:
	var hsm = HighScoreManager.get_instance()
	var scores = hsm.get_top_scores()
	
	# Remove previous score row containers (but keep header and title)
	for child in vbox.get_children():
		if child is HBoxContainer and child != header_container:
			child.queue_free()
	
	var rows = []
	
	if scores.size() == 0:
		var msg_hbox = HBoxContainer.new()
		var msg_label = Label.new()
		msg_label.text = "No hay puntuaciones guardadas"
		msg_label.horizontal_alignment = 1  # CENTER
		msg_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_apply_header_style(msg_label)
		msg_hbox.add_child(msg_label)
		rows.append(msg_hbox)
	else:
		for score in scores:
			var player_name: String = score["name"]
			var time: int = score["time"]
			
			var hbox = HBoxContainer.new()
			
			var name_label = Label.new()
			name_label.text = player_name
			name_label.horizontal_alignment = 0  # LEFT
			name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			_apply_header_style(name_label)
			
			var time_label = Label.new()
			time_label.text = str(time) + " sec"
			time_label.horizontal_alignment = 2  # RIGHT
			_apply_header_style(time_label)
			
			hbox.add_child(name_label)
			hbox.add_child(time_label)
			rows.append(hbox)
	
	# Append new rows to the VBoxContainer
	for row in rows:
		vbox.add_child(row)
	
	# Move the back button to the bottom
	if button_back in vbox.get_children():
		vbox.move_child(button_back, vbox.get_child_count() - 1)


func _apply_header_style(label: Label) -> void:
	# Use the same font and size as the header labels
	var font = header_name_label.get_theme_font("font")
	if font:
		label.add_theme_font_override("font", font)
	var font_size = header_name_label.get_theme_font_size("font_size")
	if font_size > 0:
		label.add_theme_font_size_override("font_size", font_size)


func _toggle_fullscreen() -> void:
	var window_mode = DisplayServer.window_get_mode()
	if window_mode == DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
