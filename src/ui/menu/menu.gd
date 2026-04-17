extends Control

@onready var button_play: Button = $VBoxContainer/Button_PLAY
@onready var button_score: Button = $VBoxContainer/Button_SCORE
@onready var button_exit: Button = $VBoxContainer/Button_EXIT

func _ready() -> void:
	button_play.pressed.connect(_on_play_pressed)
	button_score.pressed.connect(_on_score_pressed)
	button_exit.pressed.connect(_on_exit_pressed)


func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://src/stages/main_scene.tscn")

func _on_score_pressed() -> void:
	get_tree().change_scene_to_file("res://src/ui/menu/scores.tscn")

func _on_exit_pressed() -> void:
	get_tree().quit()
