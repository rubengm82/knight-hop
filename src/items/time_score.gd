extends Node2D

@onready var label_seconds: Label = $Label_seconds
var seconds: int = 1	#Segundos que inicia el contador

func _ready() -> void:
	label_seconds.text = str(seconds)
	$Timer.start()

#Cada vez que el Wait Time del nodo Timer acaba a 1seg suma uno al contador
func _on_timer_timeout() -> void:
	seconds += 1
	label_seconds.text = str(seconds)
