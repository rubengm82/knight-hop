extends Control

@onready var button_back: Button = $VBoxContainer/Button_BACK
@onready var label_scores: Label = $VBoxContainer/Label_SCORES

func _ready() -> void:
	button_back.pressed.connect(_on_back_pressed)
	_display_scores()


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://src/ui/menu/menu.tscn")


func _display_scores() -> void:
	var hsm = HighScoreManager.get_instance()
	var scores = hsm.get_top_scores()
	
	if scores.size() == 0:
		label_scores.text = "No hay puntuaciones guardadas"
		return
	
	var scores_text: String = ""
	for score in scores:
		var player_name: String = score["name"]
		var time: float = score["time"]
		var minutes: int = int(time / 60)
		var seconds: float = fmod(time, 60)
		var seconds_str: String = "%06.3f" % seconds
		seconds_str = seconds_str.replace(".", ":")
		scores_text += player_name + " - " + str(minutes).pad_zeros(2) + ":" + seconds_str + "\n"
	
	label_scores.text = scores_text
