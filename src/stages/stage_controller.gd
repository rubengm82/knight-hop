extends Node2D

# Variables para contar monedas
var monedas_coleccionadas: int = 0
var monedas_totales: int = 0

# Referencias a los nodos
@onready var door = $Door

func _ready() -> void:
	# Buscar todas las monedas en el nivel
	var coins = []
	for child in get_children():
		if child.name.begins_with("Coin"):
			coins.append(child)
	
	monedas_totales = coins.size()
	
	# Conectar las señales de las monedas
	for coin in coins:
		if coin.has_signal("coin_collected"):
			coin.coin_collected.connect(_on_coin_collected)
	
	# Asegurarse de que la puerta no estéabierta al inicio
	if door.has_method("close_door"):
		door.close_door()
	
	print("Nivel listo. Monedas totales: ", monedas_totales)

func _on_coin_collected() -> void:
	monedas_coleccionadas += 1
	print("Monedas: ", monedas_coleccionadas, "/", monedas_totales)
	
	# Si se recolectaron todas las monedas, abrir la puerta
	if monedas_totales > 0 and monedas_coleccionadas >= monedas_totales:
		_open_door()

func _open_door() -> void:
	if door.has_method("open_door"):
		door.open_door()
		print("¡Puerta abierta! Puedes pasar al siguiente nivel.")

# Función llamada cuando el knight toca la puertaabierta
func next_level() -> void:
	print("Cambiando al siguiente nivel...")
	# Obtener la referencia al MainScene (nodo padre del padre)
	var main_scene = get_parent()
	if main_scene.has_method("crear_nivel"):
		# Incrementar el nivel actual
		main_scene._nivel_actual += 1
		# Usar call_deferred para crear el nuevo nivel en el siguiente frame
		main_scene.crear_nivel.call_deferred(main_scene._nivel_actual)
