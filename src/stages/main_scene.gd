extends Node2D

@export var niveles: Array[PackedScene]

var _nivel_actual: int = 1
var _nivel_instanciado: Node


func _ready() -> void:
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
	
	_nivel_instanciado = niveles[numero_nivel - 1].instantiate()
	add_child.call_deferred(_nivel_instanciado)

func eliminar_nivel():
	_nivel_instanciado.queue_free()
	
func reiniciar_nivel():
	eliminar_nivel()
	crear_nivel.call_deferred(_nivel_actual)
