extends Node2D

@onready var label_seconds: Label = $Label_seconds
@export var segundos_inicio: int = 1	# Segundos que inicia el contador
@export var activar_contador: bool = true	# Si true, el contador empieza a contar

var seconds: int = 0

func _ready() -> void:
	seconds = segundos_inicio - 1  # Se suma 1 en el primer tick, así que empezamos uno menos
	label_seconds.text = str(segundos_inicio - 1)
	
	if activar_contador:
		$Timer.start()
	else:
		$Timer.stop()

# Cada vez que el Wait Time del nodo Timer acaba a 1seg suma uno al contador
func _on_timer_timeout() -> void:
	seconds += 1
	label_seconds.text = str(seconds)

# Función para reiniciar y activar el contador
func reiniciar_contador() -> void:
	seconds = 0
	label_seconds.text = "0"
	if not activar_contador:
		activar_contador = true
		$Timer.start()
