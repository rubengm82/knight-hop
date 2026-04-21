extends Control

@onready var button_play: Button = $VBoxContainer/Button_PLAY
@onready var button_score: Button = $VBoxContainer/Button_SCORE
@onready var button_exit: Button = $VBoxContainer/Button_EXIT
@onready var line_edit_name: LineEdit = $VBoxContainer/LineEdit_NAME
@onready var audio_select: AudioStreamPlayer = $AudioPlayer_SELECT

func _ready() -> void:
	button_play.pressed.connect(_on_play_pressed)
	button_score.pressed.connect(_on_score_pressed)
	button_exit.pressed.connect(_on_exit_pressed)
	
	button_play.grab_focus()
	
	# Conectar sonido de selección al recibir foco (después de grab_focus para evitar sonido inicial)
	button_play.focus_entered.connect(_on_focus_entered)
	button_score.focus_entered.connect(_on_focus_entered)
	button_exit.focus_entered.connect(_on_focus_entered)
	
	# Configurar LineEdit con nombre por defecto y maximo 3 caracteres
	line_edit_name.text = "PLY"
	line_edit_name.max_length = 3


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("fullscreen_windowed_switch"):
		_toggle_fullscreen()


func _on_play_pressed() -> void:
	# Guardar el nombre del jugador en el HighScoreManager
	var hsm = HighScoreManager.get_instance()
	hsm.player_name = line_edit_name.text if line_edit_name.text != "" else "PLY"
	get_tree().change_scene_to_file("res://src/stages/main_scene.tscn")


func _on_score_pressed() -> void:
	get_tree().change_scene_to_file("res://src/ui/menu/scores.tscn")


func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_focus_entered() -> void:
	audio_select.play()


func _toggle_fullscreen() -> void:
	var window_mode = DisplayServer.window_get_mode()
	if window_mode == DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
