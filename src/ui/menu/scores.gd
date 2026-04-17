extends Control

@onready var button_back: Button = $VBoxContainer/Button_BACK

func _ready() -> void:
	button_back.pressed.connect(_on_back_pressed)


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://src/ui/menu/menu.tscn")
