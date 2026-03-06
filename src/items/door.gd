extends Area2D

@onready var animation: AnimatedSprite2D = $Animation
@onready var audio_open: AudioStreamPlayer = $AudioDoor_open
@onready var collision: CollisionShape2D = $Collision

var is_door_open := false
var can_transition := false

signal door_opened

func _ready() -> void:
	# Conectar la señal de animación terminada
	animation.animation_finished.connect(_on_animation_finished)
	
	# Conectar la señal body_entered directamente en el nodo Door (Area2D)
	body_entered.connect(_on_body_entered)
	
	# Iniciar con la puerta cerrada
	animation.play("close")
	is_door_open = false
	# Desactivar la colisión inicialmente para que no pase el jugador
	collision.set_deferred("disabled", true)

func open_door() -> void:
	if not is_door_open:
		is_door_open = true
		animation.frame = 0
		animation.play("open")
		collision.set_deferred("disabled", false)
		door_opened.emit()

func close_door() -> void:
	is_door_open = false
	animation.play("close")
	collision.set_deferred("disabled", true)
	
func _on_animation_finished() -> void:
	audio_open.play()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("knight") and is_door_open:
		var nivel = get_parent()
		if nivel.has_method("next_level"):
			nivel.next_level()
