extends StaticBody2D

@onready var animation: AnimatedSprite2D = $Animation
@onready var audio_open: AudioStreamPlayer = $AudioDoor_open

const ACTIVATION_DISTANCE := 50.0 # Distancia en px para activar la apertura
var is_door_open := false


func _ready() -> void:
	# Conectar la señal de animación terminada
	animation.animation_finished.connect(_on_animation_finished)

func _physics_process(_delta: float) -> void:
	# Buscar al knight en la escena
	var knight = get_tree().get_first_node_in_group("knight")
	
	if knight != null:
		# Obtener la posición del CollisionShape2D de knight
		var knight_collision = knight.get_node("Collision")
		if knight_collision:
			var knight_pos = knight.global_position + knight_collision.position
			# Calcular la distancia entre la puerta y la colisión del knight
			var distance := global_position.distance_to(knight_pos)
			
			# Si está a menos de ACTIVATION_DISTANCE píxeles, abrir la puerta
			if distance <= ACTIVATION_DISTANCE:
				if not is_door_open:
					open_door()
			# Si está a más de ACTIVATION_DISTANCE píxeles, cerrar la puerta
			else:
				if is_door_open:
					close_door()

func open_door() -> void:
	is_door_open = true
	# Reiniciar la animación al inicio antes de reproducir
	animation.frame = 0
	animation.play("open")

func close_door() -> void:
	is_door_open = false
	# Reiniciar la animación al inicio antes de reproducir
	animation.play("close")
	
func _on_animation_finished() -> void:
	# Reproducir sonido cuando termine la animación
	audio_open.play()
