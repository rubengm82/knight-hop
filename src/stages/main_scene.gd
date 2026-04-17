extends Node2D

@export var niveles: Array[PackedScene]

var _nivel_actual: int = 1
var _nivel_instanciado: Node
@onready var time_score = $TimeScore
@onready var fade_transition = $FadeTransition
var high_score_manager: HighScoreManager
var score_saved_this_run: bool = false


func _ready() -> void:
	# Conectar la señal de transición completada
	fade_transition.transicion_completada.connect(_on_transicion_completada)
	# Inicializar el gestor de puntuaciones
	high_score_manager = HighScoreManager.new()
	crear_nivel(_nivel_actual)

func _input(event: InputEvent) -> void:
	# Cheat: Saltar al siguiente nivel con la tecla 'n'
	if event is InputEventKey and event.pressed and event.keycode == KEY_N:
		_saltar_nivel()

func _saltar_nivel() -> void:
	# Verificar que no esté en el último nivel
	if _nivel_actual < niveles.size():
		_nivel_actual += 1
		crear_nivel.call_deferred(_nivel_actual)
		print("CHEAT: Saltando al nivel ", _nivel_actual)
	else:
		print("CHEAT: Ya estás en el último nivel (", _nivel_actual, ")")

func crear_nivel(numero_nivel: int):
	# Eliminar el nivel anterior si existe
	if _nivel_instanciado != null:
		eliminar_nivel()
	
	# Iniciar la transición de fundido (bloquea al jugador)
	fade_transition.iniciar_fundido()
	
	_nivel_instanciado = niveles[numero_nivel - 1].instantiate()
	add_child.call_deferred(_nivel_instanciado)
	
	# Configurar el timer según el nivel
	_configurar_timer(numero_nivel)
	
	# Si es el último nivel y aún no se ha guardado el score, guardarlo
	if numero_nivel == niveles.size() and not score_saved_this_run:
		_save_final_score()

func _configurar_timer(numero_nivel: int) -> void:
	if numero_nivel == 1:
		# Nivel 1 (tutorial): mostrar 0 y no contar
		time_score.seconds = 0
		time_score.activar_contador = false
		time_score.get_node("Label_seconds").text = "0"
		time_score.get_node("Timer").stop()
	elif numero_nivel == niveles.size():
		# Último nivel: detener el contador de tiempo
		time_score.activar_contador = false
		time_score.get_node("Timer").stop()
	elif numero_nivel == 2 and not time_score.activar_contador:
		# Solo la primera vez que pasamos al nivel 2: iniciar contador
		time_score.reiniciar_contador()
	# Si ya estaba contando, sigue contando desde donde estaba

func _save_final_score() -> void:
	var final_time = time_score.seconds
	high_score_manager.save_score(final_time)
	score_saved_this_run = true
	print("Score guardado: ", final_time, " segundos")

func eliminar_nivel():
	_nivel_instanciado.queue_free()
	
func reiniciar_nivel():
	eliminar_nivel()
	crear_nivel.call_deferred(_nivel_actual)

# Called when the fade transition completes
func _on_transicion_completada() -> void:
	# Buscar el knight en el nivel actual y habilitar movimiento
	if _nivel_instanciado != null:
		var knights = _nivel_instanciado.get_tree().get_nodes_in_group("knight")
		for knight in knights:
			if knight.has_method("set_puede_moverse"):
				knight.set_puede_moverse(true)
	print("Transición completada - Jugador puede moverse")
