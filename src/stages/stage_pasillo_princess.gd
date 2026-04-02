extends Node2D


# Función llamada cuando el knight entra en el área
func next_level() -> void:
	print("Cambiando al siguiente nivel...")
	# Obtener la referencia al MainScene (nodo padre)
	var main_scene = get_parent()
	if main_scene.has_method("crear_nivel"):
		# Incrementar el nivel actual
		var siguiente_nivel = main_scene._nivel_actual + 1
		main_scene.crear_nivel.call_deferred(siguiente_nivel)
