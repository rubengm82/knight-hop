extends ColorRect

## Señal emitida cuando termina la transición de fundido
signal transicion_completada

## Duración del fundido en segundos
@export var duracion_fundido: float = 0.5

## Color inicial (negro)
var color_inicial: Color = Color.BLACK
## Color final (transparente)
var color_final: Color = Color(0, 0, 0, 0)

## Estado de la transición
var _transicion_activa: bool = false
var _timer: float = 0.0

@onready var anim_player: AnimationPlayer

func _ready() -> void:
	# Asegurar que el ColorRect cubra toda la pantalla
	anchors_preset = Control.PRESET_FULL_RECT
	# Ocultar el ColorRect inicialmente
	color = color_inicial
	modulate.a = 1.0
	visible = false


func _process(delta: float) -> void:
	# Asegurar que siempre cubra toda la pantalla
	if size != get_viewport_rect().size:
		size = get_viewport_rect().size
		position = Vector2.ZERO
	
	if _transicion_activa:
		_timer += delta
		
		# Calcular el progreso (0.0 a 1.0)
		var progreso = clampf(_timer / duracion_fundido, 0.0, 1.0)
		
		# Interpolar el color alfa de 1 a 0 (de negro a transparente)
		var nuevo_alfa = lerpf(1.0, 0.0, progreso)
		color.a = nuevo_alfa
		
		# Cuando termine la transición
		if _timer >= duracion_fundido:
			_finalizar_transicion()


## Iniciar el fundido (de negro a transparente)
func iniciar_fundido() -> void:
	_transicion_activa = true
	_timer = 0.0
	color = color_inicial
	modulate.a = 1.0
	visible = true


## Finalizar la transición
func _finalizar_transicion() -> void:
	_transicion_activa = false
	visible = false
	emit_signal("transicion_completada")


## Obtener si la transición está activa
func esta_activa() -> bool:
	return _transicion_activa


## Obtener si el jugador puede moverse (false mientras hay transición)
func puede_jugar() -> bool:
	return not _transicion_activa
